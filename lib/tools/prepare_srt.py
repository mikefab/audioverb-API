# python3 prepare_srt.py spa eng the.clan "SUBDL.com__the.clan1307355/El Clan 2015 Argentino 720x300p h264 AAC 48KHz Makalakato.eng.srt"
import pysrt
import sys
import re

sub_from = sys.argv[1]
sub_to = sys.argv[2]
title = sys.argv[3]
file = sys.argv[4]

subs = pysrt.open('./text_files/' + file, encoding='utf-8')

for sub in subs:

    start = (sub.start.hours*3600) + (sub.start.minutes*60) + sub.start.seconds + (sub.start.milliseconds/1000)
    stop = (sub.end.hours*3600) + (sub.end.minutes*60) + sub.end.seconds + (sub.end.milliseconds/1000)
    text = sub.text.replace('\n', ' ')
    line = 'movies\t%s\t%s\t%s\t%s\t%s\t%s\t%s' % (title, sub_from, sub_to, sub.index, start, stop, re.sub('<[^<]+?>', '', text))
    print(line)
