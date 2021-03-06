#!/bin/bash
# Copyright 2019 Google LLC
#
# Licensed under the Apache License, Version 2.0 (the "License");
# you may not use this file except in compliance with the License.
# You may obtain a copy of the License at
#
#      http://www.apache.org/licenses/LICENSE-2.0
#
# Unless required by applicable law or agreed to in writing, software
# distributed under the License is distributed on an "AS IS" BASIS,
# WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
# See the License for the specific language governing permissions and
# limitations under the License.

REGION="us-central1" # choose a GCP region, e.g. "us-central1". Choose from https://cloud.google.com/ml-engine/docs/tensorflow/regions
BUCKET_NAME="dpe-sandbox" # change to your bucket name, e.g. "my-bucket"

MODEL_NAME="tf2" # change to your model name, e.g. "estimator"
MODEL_VERSION="v1" # change to your model version, e.g. "v1"

# Model Binaries corresponds to the tf.estimator.FinalExporter configuration in trainer/experiment.py
MODEL_BINARIES=gs://${BUCKET_NAME}/keras-job-dir/keras_export/
RUNTIME_VERSION=2.1
PYTHON_VERSION=3.7

gsutil ls ${MODEL_BINARIES}

# Delete model version, if previous model version exist.
gcloud ai-platform versions delete ${MODEL_VERSION} --model=${MODEL_NAME}

# Delete model, if previous model exist.
gcloud ai-platform models delete ${MODEL_NAME}

# Deploy model to GCP
gcloud ai-platform models create ${MODEL_NAME} --regions=${REGION}

# Deploy model version
gcloud ai-platform versions create ${MODEL_VERSION} \
 --model=${MODEL_NAME} \
 --origin=${MODEL_BINARIES} \
 --python-version=${PYTHON_VERSION} \
 --runtime-version=${RUNTIME_VERSION}

# Test predictions
gcloud ai-platform predict \
  --model tf2 \
  --version v1 \
  --json-instances ../input.json