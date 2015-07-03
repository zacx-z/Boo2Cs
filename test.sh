#!/bin/sh
ruby preprocess.rb samples/test.boo > tmp
txl tmp translate.txl

