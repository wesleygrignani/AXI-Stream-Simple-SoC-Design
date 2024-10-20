/******************************************************************************
*
* Copyright (C) 2009 - 2014 Xilinx, Inc.  All rights reserved.
*
* Permission is hereby granted, free of charge, to any person obtaining a copy
* of this software and associated documentation files (the "Software"), to deal
* in the Software without restriction, including without limitation the rights
* to use, copy, modify, merge, publish, distribute, sublicense, and/or sell
* copies of the Software, and to permit persons to whom the Software is
* furnished to do so, subject to the following conditions:
*
* The above copyright notice and this permission notice shall be included in
* all copies or substantial portions of the Software.
*
* Use of the Software is limited solely to applications:
* (a) running on a Xilinx device, or
* (b) that interact with a Xilinx device through a bus or interconnect.
*
* THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR
* IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY,
* FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL
* XILINX  BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER LIABILITY,
* WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM, OUT OF
* OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN THE
* SOFTWARE.
*
* Except as contained in this notice, the name of the Xilinx shall not be used
* in advertising or otherwise to promote the sale, use or other dealings in
* this Software without prior written authorization from Xilinx.
*
******************************************************************************/

/*
 * helloworld.c: simple test application
 *
 * This application configures UART 16550 to baud rate 9600.
 * PS7 UART (Zynq) is not initialized by this application, since
 * bootrom/bsp configures it to baud rate 115200
 *
 * ------------------------------------------------
 * | UART TYPE   BAUD RATE                        |
 * ------------------------------------------------
 *   uartns550   9600
 *   uartlite    Configurable only in HW design
 *   ps7_uart    115200 (configured by bootrom/bsp)
 */

#include <stdio.h>
#include "platform.h"
#include "xil_printf.h"
#include "xil_cache.h"
#include "xaxidma.h"


int main()
{
    init_platform();

    // dados que serao enviados pelo DMA
    u32 a[10];
    for(int i=0; i<10; i++){
      a[i] = i;
    }

    // espaço de memoria para receber os valores do DMA
    u32 b[10];

    // utilizado para leitura de status das funções abaixo
    u32 status;

    // struct do DMA e outra para a configuração do DMA
    XAxiDma_Config *myDmaConfig;
    XAxiDma myDma;

    // inicialização do DMA
    myDmaConfig = XAxiDma_LookupConfigBaseAddr(XPAR_AXI_DMA_0_BASEADDR);
    status = XAxiDma_CfgInitialize(&myDma, myDmaConfig);
    if(status != XST_SUCCESS){
      print("Inicialização DMA falhou!\n");
      return -1;
    }
    print("Inicialização DMA ok!\n\r");

    // Desabilita as interrupções. Sera utilizado polling
    XAxiDma_IntrDisable(&myDma, XAXIDMA_IRQ_ALL_MASK, XAXIDMA_DEVICE_TO_DMA);
    XAxiDma_IntrDisable(&myDma, XAXIDMA_IRQ_ALL_MASK, XAXIDMA_DMA_TO_DEVICE);

    // Força o processador a atualizar o conteudo especifico da memoria cache para a memoria DDR
    Xil_DCacheFlushRange((u32)b, 10*sizeof(u32));
    Xil_DCacheFlushRange((u32)a, 10*sizeof(u32));

	//configurar o DMA para realizar transferencias sem SG engine
    print("Inicio da transferencia");
	status = XAxiDma_SimpleTransfer(&myDma, (u32)&b[0], 10*sizeof(u32), XAXIDMA_DEVICE_TO_DMA);
	if(status != XST_SUCCESS){
		print("Config DMA falhou!\n");
		return -1;
	}

	status = XAxiDma_SimpleTransfer(&myDma, (u32)&a[0], 10*sizeof(u32), XAXIDMA_DMA_TO_DEVICE);
	if(status != XST_SUCCESS){
		print("Config DMA falhou!\n");
		return -1;
	}

	/* Laços de repetição são utilizados aqui para garantir que as tranferencias DMA sejam concluidas
	   Para isso, é verificado o status do canal de envio (MM2S_DMASR) e recebimento (S2MM_DMASR) de dados */
	while ((XAxiDma_Busy(&myDma, XAXIDMA_DEVICE_TO_DMA)) || (XAxiDma_Busy(&myDma, XAXIDMA_DMA_TO_DEVICE))) {
		// Espera...
	}

	for(int i=0; i<10; i++){
	  printf("%d\n", b[i]);
	}

	print("Terminou\n\r");

    cleanup_platform();
    return 0;
}
