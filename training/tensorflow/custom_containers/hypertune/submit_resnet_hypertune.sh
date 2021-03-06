export PROJECT_ID=$(gcloud config list project --format "value(core.project)")
export IMAGE_REPO_NAME=estimator-hypertune
export IMAGE_TAG=latest
export IMAGE_URI=gcr.io/$PROJECT_ID/$IMAGE_REPO_NAME:$IMAGE_TAG
now=$(date +"%Y%m%d_%H%M%S")
# GCS_BUCKET is expected as en environment variable 
#GCS_BUCKET=gs://tpu-exp-02272020
BUCKET=$GCS_BUCKET

JOB_NAME="resnet_hypertune_$now"
JOB_DIR=$BUCKET"/"$JOB_NAME

STAGING_BUCKET=$BUCKET
REGION=us-central1
DATA_DIR=gs://cloud-tpu-test-datasets/fake_imagenet
OUTPUT_PATH=$JOB_DIR

if [ "$1" = "--test_local" ]; then
    docker run $IMAGE_URI   --data_dir=$DATA_DIR   --model_dir=$OUTPUT_PATH   --resnet_depth=50   --train_steps=1024
else
  gcloud ai-platform jobs submit training $JOB_NAME \
  --scale-tier CUSTOM \
  --master-machine-type n1-highmem-8 \
  --master-accelerator count=1,type=nvidia-tesla-v100 \
  --region $REGION \
  --master-image-uri $IMAGE_URI \
  --config config_resnet_hypertune.yaml \
  -- \
  --data_dir=$DATA_DIR \
  --model_dir=$OUTPUT_PATH \
  --resnet_depth=50 \
  --train_steps=1024
fi
