dashboard -enable off
target remote localhost:1234
b *0x80200000
c
set var $ra=0
set var $sp=0
set var $gp=0
set var $tp=0
set var $t0=0
set var $t1=0
set var $t2=0
set var $fp=0
set var $s1=0
set var $a0=0
set var $a1=0
set var $a2=0
set var $a3=0
set var $a4=0
set var $a5=0
set var $a6=0
set var $a7=0
set var $s2=0
set var $s3=0
set var $s4=0
set var $s5=0
set var $s6=0
set var $s7=0
set var $s8=0
set var $s9=0
set var $s10=0
set var $s11=0
set var $t3=0
set var $t4=0
set var $t5=0
set var $t6=0
source ../../dump_changes.py
dump-changes 411