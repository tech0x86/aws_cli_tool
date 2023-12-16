#!/bin/bash

# ボリュームIDを引数から取得
VOLUME_ID=$1

if [ -z "$VOLUME_ID" ]; then
    echo "ボリュームIDが指定されていません。"
    exit 1
fi

echo "ボリューム $VOLUME_ID をデタッチします..."
aws ec2 detach-volume --volume-id $VOLUME_ID

echo "ボリュームのデタッチを待機しています..."
aws ec2 wait volume-available --volume-ids $VOLUME_ID

echo "スナップショットを作成します..."
SNAPSHOT_ID=$(aws ec2 create-snapshot --volume-id $VOLUME_ID --query 'SnapshotId' --output text)

echo "スナップショット $SNAPSHOT_ID の作成を待機しています..."
aws ec2 wait snapshot-completed --snapshot-ids $SNAPSHOT_ID

echo "ボリューム $VOLUME_ID を削除します..."
aws ec2 delete-volume --volume-id $VOLUME_ID

echo "完了しました。"

