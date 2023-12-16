#!/bin/bash

# スナップショットIDとインスタンスIDを引数から取得
SNAPSHOT_ID=$1
INSTANCE_ID=$2

if [ -z "$SNAPSHOT_ID" ] || [ -z "$INSTANCE_ID" ]; then
    echo "スナップショットIDとインスタンスIDの両方が必要です。"
    exit 1
fi

# インスタンスのアベイラビリティゾーンを取得
INSTANCE_AZ=$(aws ec2 describe-instances --instance-ids $INSTANCE_ID --query 'Reservations[0].Instances[0].Placement.AvailabilityZone' --output text)

if [ -z "$INSTANCE_AZ" ]; then
    echo "インスタンスのアベイラビリティゾーンを取得できませんでした。"
    exit 1
fi

# スナップショットからボリュームを復元（同じAZ内）
echo "スナップショット $SNAPSHOT_ID からボリュームを復元（AZ: $INSTANCE_AZ）..."
NEW_VOLUME_ID=$(aws ec2 create-volume --snapshot-id $SNAPSHOT_ID --availability-zone $INSTANCE_AZ --query 'VolumeId' --output text)

echo "ボリューム $NEW_VOLUME_ID の利用可能を待機しています..."
aws ec2 wait volume-available --volume-ids $NEW_VOLUME_ID

# ボリュームをインスタンスにアタッチ
echo "インスタンス $INSTANCE_ID にボリューム $NEW_VOLUME_ID をアタッチします..."
aws ec2 attach-volume --volume-id $NEW_VOLUME_ID --instance-id $INSTANCE_ID --device /dev/xvda

echo "処理が完了しました。"

