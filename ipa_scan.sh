#!/bin/sh

if [[ $# != 2 && $# != 1 ]]; then
  echo "USAGE: $0 ipa_file sensitive_strings"
  echo "e.g.: $0 YouriOSApp.ipa \"pgyer.com\|fir.im\|JSPatch\|dlopen\|dlsym\""
  exit 1
fi

echo "*******************************************"
echo "*****************IPA SCANER****************"
echo "*******************************************"

inputDir="ipa_scan_source/"
outputDir="ipa_scan_result/"

rm -rdf $inputDir
mkdir $inputDir
rm -rdf $outputDir
mkdir $outputDir

unzip $1 -d $inputDir

TEXTSegmentCString="_TEXT_cstring"
MATCH="__sensitive_strings__"
for filepath in `find $inputDir`; do
  if [[ -f $filepath ]]; then
    if [[ `file --mime-type $filepath` == *application/x-mach-binary* ]]; then
      echo "▶️  >>>>>>> scanning - "$filepath
      resFile=`echo $filepath | awk -F "/" '{print $NF}'`

      nm -a $filepath >> ${outputDir}${resFile%.*}
      otool -v -s __TEXT __cstring $filepath > ${outputDir}${resFile%.*}${TEXTSegmentCString}
      echo "✅ scan finished - "$filepath
      echo ""
    fi
  fi
done

if [ "$2" != "" ]; then
  find $outputDir -name "*" | xargs grep $2 > ${outputDir}${MATCH} 
fi

echo "*******************************************"
echo "**************IPA SCAN FINISHED************"
echo "*******************************************"
