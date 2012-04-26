#!/usr/bin/python

import sys
import os
from subprocess import *
import re

INPUT_PATH = os.curdir
OUTPUT_PATH = INPUT_PATH + '/output'

stack_line_re = re.compile('([0-9 ]{4}[\S ]{30,36}\t*)(0x[0-9a-f]{8})( [\S ]+\n)')

def process_crash_file(file_name, symbol_file_name, output_path):
    src_file = open(file_name)
    src_file_lines = src_file.readlines()
    src_file.close()

    output_file = open(output_path + file_name[file_name.rfind('/'):], 'w')

    for src_file_line in src_file_lines:
        match = re.match(stack_line_re, src_file_line)
        if match is not None:
            address = match.group(2)
        
            cmd_line = 'xcrun -sdk iphoneos atos -arch armv7 -o %s %s' % (symbol_file_name, address)
            p = os.popen(cmd_line)
            symbolled_text = p.read().strip()
            p.close()

            if symbolled_text != address:
                print address, '->', symbolled_text
                src_file_line = match.group(1) + match.group(2) + ' ' + symbolled_text + '\n'

        output_file.write(src_file_line)

    output_file.close()

def main():
    symbol_path_name = ''
    symbol_file_name = ''

    for file_name in os.listdir(INPUT_PATH):
        if file_name[-5:] == '.dSYM':
            symbol_path_name = file_name
            break
            
    if symbol_path_name != '':
        symbol_path_name = symbol_path_name + '/Contents/Resources/DWARF'
        for file_name in os.listdir(symbol_path_name):
            symbol_file_name = symbol_path_name + '/' + file_name
            break

    if symbol_file_name == '':
        print 'ERROR: symbol file not found'
        return

    print 'Found symbol file:', symbol_file_name

    try:
        for old_file in os.listdir(OUTPUT_PATH):
            os.remove('%s/%s' % (OUTPUT_PATH, old_file))

        os.rmdir(OUTPUT_PATH)
    except:
        pass
    finally:
        pass

    os.mkdir(OUTPUT_PATH)

    crash_files = os.listdir(INPUT_PATH)

    for crash_file_name in crash_files:
        if crash_file_name[-6:] == '.crash':
            print 'process', crash_file_name
            process_crash_file(INPUT_PATH + '/' + crash_file_name, symbol_file_name, OUTPUT_PATH)
            #cmd_line = 'symbolicatecrash "%s" %s > %s/%s' % (crash_file_name, symbol_file_name, OUTPUT_PATH, crash_file_name)
            #p = os.popen(cmd_line)

main()
