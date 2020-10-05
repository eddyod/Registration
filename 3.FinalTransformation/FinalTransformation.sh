#!/bin/bash

if (($# < 1))
then
    echo "No input brainname argument... exiting"
    exit 1
fi
#define input
ANIMAL=$1

MATLABCMD="/usr/local/bin/matlab -nodisplay -nodesktop -nosplash -r "

#define path
PIPELINE_DIR=/net/birdstore/Active_Atlas_Data/data_root/pipeline_data/
OUTPUT_DIR=$PIPELINE_DIR/$ANIMAL/preps/transformation/
ATLAS_DIR=$PIPELINE_DIR/$ANIMAL/preps/atlas
CODE_DIR=$HOME/Registration/3.FinalTransformation

#################################start process: target to registered space##############################

#1 transform high resolution images
INPUT_PATH="/data2/DKLabs Dropbox/UCSD_to_from_CSHL/$ANIMAL/"
IMG_PATH=$INPUT_PATH/DK39_img/
# IMG_PATH=/nfs/mitraweb2/mnt/disk127/main/mba_converted_imaging_data/MD721\&720/MD720/
RECON_PATH=$INPUT_PATH/Registration_OUTPUT/
##### is this used? CSV_PATH=$PIPELINE_DIR/Data/$ANIMAL/INPUT_DATA/
## make dirs
mkdir -p $OUTPUT_DIR
mkdir -p $ATLAS_DIR
mkdir -p $OUTPUT_DIR/reg_high_tif/
$MATLABCMD "cd('$CODE_DIR'); maxNumCompThreads(2); transform('$IMG_PATH', '$RECON_PATH', '$OUTPUT_DIR/reg_high_tif/'); exit"
exit

#padding the tif
mkdir -p $OUTPUT_DIR/reg_high_tif_pad/
mkdir -p $OUTPUT_DIR/reg_high_tif_pad_jp2/
$MATLABCMD "cd('$CODE_DIR'); maxNumCompThreads(2); padtif('$OUTPUT_DIR/reg_high_tif/', '$OUTPUT_DIR/reg_high_tif_pad/', '$OUTPUT_DIR/reg_high_tif_pad_jp2/');exit"

# thumbnail
sh $CODE_DIR/kdujpg.sh $OUTPUT_DIR/reg_high_tif_pad_jp2/
rm -rf $OUTPUT_DIR/reg_high_tif_pad_jp2/*.tif

# ################################start process: atlas to registered space################################
#1 transform atlas to registered space in 5um space
mkdir -p $OUTPUT_DIR/low_seg/
$MATLABCMD "cd('$CODE_DIR'); transform_seg('$ATLAS_DIR/annotation_50.vtk', '$PIPELINE_DIR/Data/$ANIMAL/INPUT_DATA/', '$RECON_PATH','$OUTPUT_DIR/low_seg/', 5); exit"

mkdir -p $OUTPUT_DIR/reg_high_seg/
$MATLABCMD "cd('$CODE_DIR'); maxNumCompThreads(2); segresize('$OUTPUT_DIR/low_seg/', '$OUTPUT_DIR/reg_high_tif/', '$OUTPUT_DIR/reg_high_seg/'); exit"


mkdir -p $OUTPUT_DIR/reg_high_seg_pad/
$MATLABCMD "cd('$CODE_DIR'); maxNumCompThreads(2); padseg('$OUTPUT_DIR/reg_high_seg/', '$OUTPUT_DIR/reg_high_seg_pad/'); done('$ANIMAL'); exit"

#cd $CODE_DIR/makejson/
#python brain_region.py $ANIMAL

#cd $CODE_DIR
#python update_database.py $ANIMAL
