#! /bin/bash
envMy=$1;
gitMy=$2;
tagMy=$3;
service=$4;
timeMy=`date  +%Y%m%d%H%M%S`;

root="/data/sys_work/$service/";
rm -rf $root;
mkdir -p $root;
git clone $gitMy $root -q;
cd $root;
git checkout -b ci $tagMy  2>&1;

if [ -d "devOps" ]; then
   \cp devOps/$envMy/*  .
   bash pod.sh $tagMy  2>&1;
   echo "{\"code\":\"200\" , \"env\":\"$1\" , \"git\": \"$2\" , \"tag\":\"$3\" , \"service\":\"$4\"}"
else
   echo "{\"code\":\"404\" , \"env\":\"$1\" , \"git\": \"$2\" , \"tag\":\"$3\" , \"service\":\"$4\"}"
fi

