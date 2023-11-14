#!/usr/bin/env bash
#
# workflowtests/upload_assets_tests.sh

# THE INTENT OF THIS FILE IS TO BE IMPORTED DIRECTLY BY THE 'WORKFLOWTESTS.SH'
# FILE. THIS SHOULD RAN DIRECTLY OR IMPORTED BY ANY OTHER BASH SCRIPT.

printstep "Testing 'upload-assets.yml' Workflow..."

echo -e "$("$SCRIPTS_DIR/printformat.sh" "foreground:blue" "***") Creating zip archive for $("$SCRIPTS_DIR/printformat.sh" "bold" "$PRODUCT_NAME.xcframework")"
zip -rX "$PRODUCT_NAME.xcframework.zip" "$PRODUCT_NAME.xcframework" >/dev/null 2>&1
checkresult $? "'Create XCFramework Zip' step of 'upload-assets.yml' workflow failed."

echo -e "$("$SCRIPTS_DIR/printformat.sh" "foreground:blue" "***") Creating tar archive for $("$SCRIPTS_DIR/printformat.sh" "bold" "$PRODUCT_NAME.xcframework")"
tar -zcvf "$PRODUCT_NAME.xcframework.tar.gz" "$PRODUCT_NAME.xcframework" >/dev/null 2>&1
checkresult $? "'Create XCFramework Tar' step of 'upload-assets.yml' workflow failed."

#

DOCC_ARCHIVE="$(find "$OUTPUT_DIR/.xcodebuild" -type d -name "$PRODUCT_NAME.doccarchive")"

if [ "${DOCC_ARCHIVE[@]]}" == "0" ]; then
    checkresult 1 "'Build Documentation' step of 'upload-assets.yml' workflow failed."
else
    mv "${DOCC_ARCHIVE%/}" "$OUTPUT_DIR/$PRODUCT_NAME.doccarchive"
    checkresult $? "'Build Documentation' step of 'upload-assets.yml' workflow failed."
fi

#

echo -e "$("$SCRIPTS_DIR/printformat.sh" "foreground:blue" "***") Creating zip archive for $("$SCRIPTS_DIR/printformat.sh" "bold" "$PRODUCT_NAME.doccarchive")"
zip -rX "$PRODUCT_NAME.doccarchive.zip" "$PRODUCT_NAME.doccarchive" >/dev/null 2>&1
checkresult $? "'Create Documentation Zip' step of 'upload-assets.yml' workflow failed."

echo -e "$("$SCRIPTS_DIR/printformat.sh" "foreground:blue" "***") Creating tar archive for $("$SCRIPTS_DIR/printformat.sh" "bold" "$PRODUCT_NAME.doccarchive")"
tar -zcvf "$PRODUCT_NAME.doccarchive.tar.gz" "$PRODUCT_NAME.doccarchive" >/dev/null 2>&1
checkresult $? "'Create Documentation Tar' step of 'upload-assets.yml' workflow failed."

printstep "'upload-assets.yml' Workflow Tests Passed\n"
