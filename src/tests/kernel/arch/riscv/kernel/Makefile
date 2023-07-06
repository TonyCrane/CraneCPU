ASM_SRC		= $(sort $(wildcard *.S))
# wildcard 意思是找出所有的 .S 文件，sort 意思是对文件名进行排序，这样可以保证编译的顺序
C_SRC       = $(sort $(wildcard *.c))
OBJ		    = $(patsubst %.S,%.o,$(ASM_SRC)) $(patsubst %.c,%.o,$(C_SRC))
# patsubst 意思是将 .S 文件替换成 .o 文件，将 .c 文件替换成 .o 文件

all:$(OBJ)


%.o:%.S
	${GCC}  ${CFLAG} -c $<
# $< 意思是依赖文件的名字，$@ 意思是目标文件的名字
# -c 意思是只编译，不链接

%.o:%.c
	${GCC}  ${CFLAG} -c $<

clean:
	$(shell rm *.o 2>/dev/null)