#/usr/bin/env bash
# -w sets workspace dir for build
# -s sets git source dir for build
# -e sets exclusions dir for build
# -b sets destination dir for build
# -d sets temporary destination dir for deletions in build
# -p sets prior commit for build (foundation of git diff command)
# -c sets current commit for build
# -t sets project type (sfdx or mdapi) for build

#default arg values
WSPACE="`pwd`"
ROOTDIR=.
SRCDIR=force-app/main/default
EXCLDIR=exclusions
BUILDDIR=staging
DESTROYDIR=toDelete
PRIORCOMMIT=HEAD~1
CURRCOMMIT=HEAD
PROJECTTYPE=sfdx
#read command line args
while getopts w:r:s:e:b:d:p:c:t: option
do
        case "${option}"
        in
                w) WSPACE=${OPTARG};;
                r) ROOTDIR=${OPTARG};;
                s) SRCDIR=${OPTARG};;
                e) EXCLDIR=${OPTARG};;
                b) BUILDDIR=${OPTARG};;
                d) DESTROYIR=${OPTARG};;
                p) PRIORCOMMIT=${OPTARG};;
                c) CURRCOMMIT=${OPTARG};;
                t) PROJECTTYPE=${OPTARG};;
        esac
done



echo Workspace: $WSPACE
echo Git Root Directory: $ROOTDIR
echo Source Directory: $SRCDIR
echo Excluded Directory: $EXCLDIR
echo Build Directory: $BUILDDIR
echo Temporary Destroy Directory: $DESTROYDIR
echo Prior Commit: $PRIORCOMMIT
echo Current Commit: $CURRCOMMIT
echo Project Type: $PROJECTTYPE

if [[ $PROJECTTYPE == "mdapi" ]]
then
    SRCDIR=src
fi

cd "$WSPACE"
#echo Changing directoy to $WSPACE

if [ -d "$WSPACE/$BUILDDIR" ]
then
    rm -rf $BUILDDIR
    #echo Delete pre-existing $BUILDDIR directory
fi
mkdir $BUILDDIR
#echo Creating $BUILDDIR directory
if [ -d "$WSPACE/$DESTROYDIR" ]
then
    rm -rf $DESTROYDIR
    #echo Delete pre-existing $DESTROYDIR directory
fi
cd $ROOTDIR
#echo Changing directory to $ROOTDIR
if [ ! -z "$PRIORCOMMIT" ]
then
        git diff --diff-filter=d -z --name-only $PRIORCOMMIT $CURRCOMMIT -- . ":!$EXCLDIR" -- . ":!*.*ignore" | xargs -0 -IREPLACE rsync -aR REPLACE "$WSPACE/$BUILDDIR/$ROOTDIR"
        #echo Moving changed files to $BUILDDIR folder
        IFS=$'\n';
        if [ -d "$WSPACE/$BUILDDIR/$SRCDIR" ]
        then
            for f in $(find "$WSPACE/$BUILDDIR/$SRCDIR" -name '*-meta.xml')
            do
                    BNAME=`basename $f`
                    BNAME="${BNAME//-meta.xml}"
                    DIR=`dirname $f`
                    DIR=${DIR##*$SRCDIR/}
                    if [[ $DIR == "aura/"* ]]
                    then
                            cp -Rpv "$WSPACE/$SRCDIR/$DIR" "$WSPACE/$BUILDDIR/$SRCDIR/aura/"
                    elif [[ $DIR == "lwc/"* ]]
                    then
                            cp -Rpv "$WSPACE/$SRCDIR/$DIR" "$WSPACE/$BUILDDIR/$SRCDIR/lwc/"
                    else
                            cp -pv "$WSPACE/$SRCDIR/$DIR/$BNAME" "$WSPACE/$BUILDDIR/$SRCDIR/$DIR/"
                    fi
            done
            #echo Moving all related components to changed metadata files and all related aura/lwc files within a changed bundle to $BUILDDIR folder
            for f in $(find "$WSPACE/$BUILDDIR/$SRCDIR" -name '*.cls' -or -name '*.component' -or -name '*.page' -or -name '*.resource' -or -name '*.trigger' -or -name '*.app' -not -not -path '$SRCDIR/applications/*' -or -name '*.cmp' -or -name '*.design' -or -name '*.evt' -or -name '*.intf' -or -name '*.js' -or -name '*.svg' -or -name '*.css' -or -name '*.auradoc' -or -name '*.tokens' -or -name '*.html' -or -name '*.js-meta.xml' -or -name '*.js-meta.xml')
            do
                    BNAME=`basename $f`
                    BNAME="$BNAME-meta.xml"
                    DIR=`dirname $f`
                    DIR=${DIR##*$SRCDIR/}
                    #echo $DIR
                    if [[ $DIR == "aura/"* ]]
                    then
                            cp -Rpv "$WSPACE/$SRCDIR/$DIR" "$WSPACE/$BUILDDIR/$SRCDIR/aura/"
                    elif [[ $DIR == "lwc/"* ]]
                    then
                            cp -Rpv "$WSPACE/$SRCDIR/$DIR" "$WSPACE/$BUILDDIR/$SRCDIR/lwc/"
                    else
                            cp -pv "$WSPACE/$SRCDIR/$DIR/$BNAME" "$WSPACE/$BUILDDIR/$SRCDIR/$DIR/"
                    fi
            done
        fi
        #echo Moving all metadata files related to deleted components and all related aura/lwc files within a changed bundle to $BUILDDIR folder
        if [ `git diff --diff-filter=D -z --name-only $PRIORCOMMIT $CURRCOMMIT` ]
        then
                mkdir $DESTROYDIR
                #echo Creating $DESTROYDIR directory
                rm -f deletedFiles.txt
                #echo Deleting pre-existing deletedFiles.txt list
                git diff --diff-filter=D -z --name-only $PRIORCOMMIT $CURRCOMMIT | xargs -0 -IDELFILE echo "DELFILE" >> deletedFiles.txt
                #echo Creating new deletedFiles.txt list
                IFS=$'\n';
                while read CFILE
                do
                        #echo Analyzing file `basename $CFILE`
                        BNAME=`basename $CFILE`
                        BNAME="${BNAME//-meta.xml}"
                        DIR=`dirname $CFILE`
                        DIR=${DIR##*$SRCDIR/}
                        #echo Directory is $DIR
                        if [[ -d "$SRCDIR/$DIR" && "$(ls -A $SRCDIR/$DIR)" && $DIR == "aura/"* ]]
                        then
                                #echo "Lightning component metadata has been deleted, but the component bundle still exists with files so the bundle should be incorporated for updating, not total deletion"
                                mkdir -p "$WSPACE/$BUILDDIR/$SRCDIR/aura/" && cp -Rpv "$WSPACE/$SRCDIR/$DIR" "$WSPACE/$BUILDDIR/$SRCDIR/aura/"
                        elif [[ -d "$SRCDIR/$DIR" && "$(ls -A $SRCDIR/$DIR)" && $DIR == "lwc/"* ]]
                        then
                                #echo "Lightning web component metadata has been deleted, but the component bundle still exists with files so the bundle should be incorporated for updating, not total deletion"
                                mkdir -p "$WSPACE/$BUILDDIR/$SRCDIR/lwc/" && cp -Rpv "$WSPACE/$SRCDIR/$DIR" "$WSPACE/$BUILDDIR/$SRCDIR/lwc/"
                        else
                                #echo "Either the metadata deleted is not part of a component bundle or the entire bundle has been deleted"
                                mkdir -p "$WSPACE/$DESTROYDIR/$SRCDIR/$DIR" && echo "'$BNAME is going to be deleted!'" > "$WSPACE/$DESTROYDIR/$SRCDIR/$DIR/$BNAME"
                        fi
                done < deletedFiles.txt
        else
                echo "No metadata deleted"
        fi
        if [[ $PROJECTTYPE == "mdapi" ]]
        then
            read -d '' NEWPKGXML <<EOF
<?xml version="1.0" encoding="UTF-8"?>
<Package>
</Package>
EOF
        #echo ===PKGXML===
        #echo $NEWPKGXML
        #echo Creating new package.xml
        #echo $NEWPKGXML > "$WSPACE/$BUILDDIR/$SRCDIR/package.xml"

        declare -a elementArray
        IFS=$'\n'
        for CFILE in $(find "$WSPACE/$BUILDDIR")
        do
                #echo Analyzing file `basename $CFILE`

                case "$CFILE"
                in
                        *.cls*) TYPENAME="ApexClass";;
                        *.page*) TYPENAME="ApexPage";;
                        *.component*) TYPENAME="ApexComponent";;
                        *.trigger*) TYPENAME="ApexTrigger";;
                        **/aura/**/*.app*) TYPENAME="AuraDefinitionBundle";;
                        **/aura/**/*.cmp*) TYPENAME="AuraDefinitionBundle";;
                        **/aura/**/*.design*) TYPENAME="AuraDefinitionBundle";;
                        **/aura/**/*.evt*) TYPENAME="AuraDefinitionBundle";;
                        **/aura/**/*.intf*) TYPENAME="AuraDefinitionBundle";;
                        **/aura/**/*.tokens*) TYPENAME="AuraDefinitionBundle";;
                        **/lwc/**/*.css*) TYPENAME="LightningComponentBundle";;
                        **/lwc/**/*.html*) TYPENAME="LightningComponentBundle";;
                        **/lwc/**/*.js*) TYPENAME="LightningComponentBundle";;
                        **/lwc/**/*.js-meta.xml*) TYPENAME="LightningComponentBundle";;
                        **/lwc/**/*.svg*) TYPENAME="LightningComponentBundle";;
                        *.app*) TYPENAME="CustomApplication";;
                        *.labels*) TYPENAME="CustomLabels";;
                        *.object*) TYPENAME="CustomObject";;
                        **/customMetadata/*.md*) TYPENAME="CustomMetadata";;
                        *.tab*) TYPENAME="CustomTab";;
                        *.pagelayout*) TYPENAME="Layout";;
                        *.permissionset*) TYPENAME="PermissionSet";;
                        *.profile*) TYPENAME="Profile";;
                        *.remoteSite*) TYPENAME="RemoteSiteSettings";;
                        *.resource*) TYPENAME="StaticResource";;
                        *.workflow*) TYPENAME="Workflow";;
                        *) TYPENAME="UNKNOWN TYPE";;
                esac

                if [[ "$TYPENAME" != "UNKNOWN TYPE" ]]
                then
                        ENTITY=$(basename "$CFILE")
                        ENTITY="${ENTITY%.*}"
                        ENTITY="${ENTITY//.*-meta*}"
                        #echo ENTITY NAME: $ENTITY

                        if grep -Fq "$TYPENAME" "$WSPACE/$BUILDDIR/$SRCDIR/package.xml"
                        then
                                if [[ ! " ${elementArray[@]} " =~ " $TYPENAME$ENTITY " ]]
                                then
                                        #echo Generating new member for $ENTITY
                                        xmlstarlet ed -L -s "/Package/types[name='$TYPENAME']" -t elem -n members -v "$ENTITY" "$WSPACE/$BUILDDIR/$SRCDIR/package.xml"
                                        elementArray+=($TYPENAME$ENTITY)
                                fi
                        else
                                #echo Generating new $TYPENAME type
                                xmlstarlet ed -L -s /Package -t elem -n types -v "" "$WSPACE/$BUILDDIR/$SRCDIR/package.xml"
                                xmlstarlet ed -L -s '/Package/types[not(*)]' -t elem -n name -v "$TYPENAME" "$WSPACE/$BUILDDIR/$SRCDIR/package.xml"
                                #echo Generating new member for $ENTITY
                                xmlstarlet ed -L -s "/Package/types[name='$TYPENAME']" -t elem -n members -v "$ENTITY" "$WSPACE/$BUILDDIR/$SRCDIR/package.xml"
                                elementArray+=($TYPENAME$ENTITY)
                        fi
                else
                        echo ERROR: UNKNOWN FILE TYPE $CFILE
                fi
                #echo ====UPDATED PACKAGE.XML====
                cat "$WSPACE/$BUILDDIR/$SRCDIR/package.xml"
        done
        #echo Cleaning up Package.xml
        xmlstarlet ed -L -s /Package -t elem -n version -v "45.0" "$WSPACE/$BUILDDIR/$SRCDIR/package.xml"
        xmlstarlet ed -L -i /Package -t attr -n xmlns -v "http://soap.sforce.com/2006/04/metadata" "$WSPACE/$BUILDDIR/$SRCDIR/package.xml"

        #echo ====FINAL PACKAGE.XML=====
        #cat "$WSPACE/$BUILDDIR/$SRCDIR/package.xml"
        fi
        if [[ -d "$WSPACE/$DESTROYDIR" ]]
        then
                read -d '' NEWDESTROYXML <<EOF
<?xml version="1.0" encoding="UTF-8"?>
<Package>
</Package>
EOF
                #echo ===DESTROYXML===
                #echo $NEWDESTROYXML
                #echo Creating new destructiveChangesPost.xml
                echo $NEWDESTROYXML > "$WSPACE/$DESTROYDIR/destructiveChangesPost.xml"
                declare -a destroyElementArray
                IFS=$'\n'
                for CFILE in $(find "$WSPACE/$DESTROYDIR")
                do
                        #echo Analyzing file `basename $CFILE`

                        case "$CFILE"
                        in
                                *.cls*) TYPENAME="ApexClass";;
                                *.page*) TYPENAME="ApexPage";;
                                *.component*) TYPENAME="ApexComponent";;
                                *.trigger*) TYPENAME="ApexTrigger";;
                                **/aura/**/*.app*) TYPENAME="AuraDefinitionBundle";;
                                **/aura/**/*.cmp*) TYPENAME="AuraDefinitionBundle";;
                                **/aura/**/*.design*) TYPENAME="AuraDefinitionBundle";;
                                **/aura/**/*.evt*) TYPENAME="AuraDefinitionBundle";;
                                **/aura/**/*.intf*) TYPENAME="AuraDefinitionBundle";;
                                **/aura/**/*.tokens*) TYPENAME="AuraDefinitionBundle";;
                                **/lwc/**/*.css*) TYPENAME="LightningComponentBundle";;
                                **/lwc/**/*.html*) TYPENAME="LightningComponentBundle";;
                                **/lwc/**/*.js*) TYPENAME="LightningComponentBundle";;
                                **/lwc/**/*.js-meta.xml*) TYPENAME="LightningComponentBundle";;
                                **/lwc/**/*.svg*) TYPENAME="LightningComponentBundle";;
                                *.app*) TYPENAME="CustomApplication";;
                                *.labels*) TYPENAME="CustomLabels";;
                                *.object*) TYPENAME="CustomObject";;
                                **/customMetadata/*.md*) TYPENAME="CustomMetadata";;
                                *.tab*) TYPENAME="CustomTab";;
                                *.pagelayout*) TYPENAME="Layout";;
                                *.remoteSite*) TYPENAME="RemoteSiteSettings";;
                                *.resource*) TYPENAME="StaticResource";;
                                *.workflow*) TYPENAME="Workflow";;
                                *) TYPENAME="UNKNOWN TYPE";;
                        esac

                        if [[ "$TYPENAME" != "UNKNOWN TYPE" ]]
                        then
                                ENTITY=$(basename "$CFILE")
                                ENTITY="${ENTITY%.*}"
                                ENTITY="${ENTITY//.*-meta*}"
                                #echo ENTITY NAME: $ENTITY

                                if grep -Fq "$TYPENAME" "$WSPACE/$DESTROYDIR/destructiveChangesPost.xml"
                                then
                                        if [[ ! " ${destroyElementArray[@]} " =~ " $TYPENAME$ENTITY " ]]
                                        then
                                                #echo Generating new member for $ENTITY
                                                xmlstarlet ed -L -s "/Package/types[name='$TYPENAME']" -t elem -n members -v "$ENTITY" "$WSPACE/$DESTROYDIR/destructiveChangesPost.xml"
                                                destroyElementArray+=($TYPENAME$ENTITY)
                                        fi
                                else
                                        #echo Generating new $TYPENAME type
                                        xmlstarlet ed -L -s /Package -t elem -n types -v "" "$WSPACE/$DESTROYDIR/destructiveChangesPost.xml"
                                        xmlstarlet ed -L -s '/Package/types[not(*)]' -t elem -n name -v "$TYPENAME" "$WSPACE/$DESTROYDIR/destructiveChangesPost.xml"
                                        #echo Generating new member for $ENTITY
                                        xmlstarlet ed -L -s "/Package/types[name='$TYPENAME']" -t elem -n members -v "$ENTITY" "$WSPACE/$DESTROYDIR/destructiveChangesPost.xml"
                                        destroyElementArray+=($TYPENAME$ENTITY)
                                fi
                        #else
                                #echo ERROR: UNKNOWN FILE TYPE $CFILE
                        fi
                        #echo ====UPDATED destructiveChangesPost.xml====
                        #cat "$WSPACE/$DESTROYDIR/destructiveChangesPost.xml"
                done
                #echo Cleaning up destructiveChangesPost.xml
                xmlstarlet ed -L -s /Package -t elem -n version -v "45.0" "$WSPACE/$DESTROYDIR/destructiveChangesPost.xml"
                xmlstarlet ed -L -i /Package -t attr -n xmlns -v "http://soap.sforce.com/2006/04/metadata" "$WSPACE/$DESTROYDIR/destructiveChangesPost.xml"

                #echo ====FINAL destructiveChangesPost.xml=====
                #cat "$WSPACE/$DESTROYDIR/destructiveChangesPost.xml"
        else
            RUNDELETE=0
        fi
else
        #echo No prior commit found, default Package.xml will be used
        rsync -aRv --exclude="$SRCDIR/*.*ignore" --exclude="$SRCDIR/**/*.*ignore" --exclude="$SRCDIR/.git/" --exclude="$SRCDIR/**/.git/" --exclude="$SRCDIR/$EXCLDIR/" --exclude="$SRCDIR/**/$EXCLDIR/" $SRCDIR $BUILDDIR/
        #echo Moving files to $BUILDDIR folder
fi
#echo Return to workspace directory
cd "$WSPACE"
if [[ $PROJECTTYPE == "mdapi" ]]
then
    #Deploy to prod & run all tests
    echo "Deploying to production & running all tests..."
    sfdx force:mdapi:deploy -c -d $BUILDDIR -u ExtraCurricularDevHub -l RunLocalTests -w -1
else
    #Convert to MDAPI format for deployment to prod
    echo "Converting to MDAPI format..."
    if [[ $RUNDELETE == 0 ]]
    then
        mkdir $DESTROYDIR
    fi
    if [ -d "$WSPACE/$BUILDDIR/force-app/" ]
    then
        sfdx force:source:convert -d deploy_prod -r $BUILDDIR/force-app/
    fi
    if [[ $RUNDELETE == 0 ]]
    then
        rm -rf $DESTROYDIR
    fi
    if [ -d "$WSPACE/$DESTROYDIR/force-app/" ]
    then
        sfdx force:source:convert -d $DESTROYDIR -r $DESTROYDIR/force-app/
    fi
    #Deploy to prod & run all tests
    echo "Deploying to production & running all tests..."
    if [ -d "$WSPACE/deploy_prod" ]
    then
        sfdx force:mdapi:deploy -d deploy_prod -u ExtraCurricularDevHub -l RunLocalTests -w -1
        rm -rf deploy_prod
    fi
    if [[ $RUNDELETE != 0 ]]
    then
        rm -rf $DESTROYDIR/force-app/
        read -d '' EMPTYPACKAGEXML <<EOF
<?xml version="1.0" encoding="UTF-8"?>
<Package>
</Package>
EOF
        echo $EMPTYPACKAGEXML > "$WSPACE/$DESTROYDIR/package.xml"
        xmlstarlet ed -L -s /Package -t elem -n version -v "45.0" "$WSPACE/$DESTROYDIR/package.xml"
        xmlstarlet ed -L -i /Package -t attr -n xmlns -v "http://soap.sforce.com/2006/04/metadata" "$WSPACE/$DESTROYDIR/package.xml"
        sfdx force:mdapi:deploy -d $DESTROYDIR -u ExtraCurricularDevHub -l RunLocalTests -w -1
    fi

fi
