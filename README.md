# CraneCPU

> 浙江大学计算机系统贯通课程硬件实验
>
> **Warning**: 仅供参考，请勿抄袭

## 实验进度

系统贯通课程会逐步实现一个 RISC-V 五级流水线 CPU，并实现异常处理、分支预测、Cache、MMU 等功能，并在其上运行自己编写的简易 kernel。

本 repo 通过分支、tag 等来记录实验进度，保存各阶段成果。

- [x] 系统 Ⅰ lab5-1/lab5-2：单周期 CPU
- [x] extra：单周期 CPU with 特权指令/异常处理
- [x] 系统 Ⅱ lab1：流水线 CPU (stall)
- [x] 系统 Ⅱ lab2：流水线 CPU (forwarding)
- [x] 系统 Ⅱ lab7：流水线 CPU with 特权指令/异常处理
    - **Note**: 实际上这个 lab 做的比较不完善，只实现了 csrr 和 csrw 能跑，特权级基本功能还不全，有待改进
- [x] 系统 Ⅲ lab1：流水线 CPU with 动态分支预测
    - 使用了提供的实验框架而非自己的，就不放在 repo 里了
- [x] 系统 Ⅲ lab2：流水线 CPU with Cache
    - 使用了提供的实验框架而非自己的，就不放在 repo 里了
- [x] 系统 Ⅲ lab Xpart：软硬件贯通实验，主要部分是实现 MMU 以及调试 kernel
    - RV64IZicsr 全部指令（除去 fence ebreak wfi）
    - 包含 Supervisor 和 User 两个特权级
    - 实现了 Bare 和 Sv39 两种分页模式
    - 支持串口输出
    - 展示 slides 在：[slides.tonycrane.cc/sys3-xpart-pre](https://slides.tonycrane.cc/sys3-xpart-pre/)

## 实验环境

课内使用 vivado 以及 Nexys A7-100T FPGA 开发板进行实验。

为了在非 Windows 平台开发/仿真方便，使用了 [Icarus Verilog](https://github.com/steveicarus/iverilog) 以及 [GTKWave](https://github.com/gtkwave/gtkwave/) 进行仿真。

## 编译与仿真

使用了一个 Makefile 来整合编译、仿真等操作：

- `make`：编译、仿真，并打开 GTKWave 查看波形
- `make compile`：编译
- `make simulate`：仿真，并打开 GTKWave 查看波形

需要通过 `GTKWAVE=/path/to/your/gtkwave` 来指定 GTKWave 的路径。

## 声明

没有认真学过 verilog，写的都挺屎的，反正能跑就行，跑起来了也就懒得改了。仅供参考，参考价值或许也不那么大（x，那就仅供记录（✓

## LICENSE

都是基于 [starter code](https://github.com/TonyCrane/CraneCPU/commit/08b1c5129c9c933bebcf9a755afddb13f8b7d679) 完全自己写的，就用个 MIT License 吧。