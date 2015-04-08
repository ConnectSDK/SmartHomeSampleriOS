#!/usr/bin/env sed -Ef
s/(NSString \*const .* = ).*/\1@"CHANGE_ME";/g
s!(const unsigned char .*\[\] = ).*!\1{0x00, 0xff /*CHANGE_ME*/};!g
