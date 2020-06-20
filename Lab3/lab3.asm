.model large

.stack 100h

.data
    
    matrix          dw  1000   DUP (?);
    height          db  3;
    weidth          db  3;
    
    vectorResult    dd  11   DUP (1);        
    
    NumBuf16        db  8; 
    NumSize16       db  ?;                                                      
    NumSign16       db  ?;
    NumMod16        db  8   DUP ('$');

    WordBuffer1     dw  ?;
    WordBuffer2     dw  ?;
    WordBuffer3     dw  0h;                                                                                                                                
    
    msgSTART        db  "  ================================ Program Start =================================$";
    msgHead         db  "      +0     +1     +2     +3     +4     +5     +6     +8     +9     +10    +11   $";
    msgSpace        db  "                                                                                  $";
    msgEnterHeight  db  "  Enter matrix height(0 - 10): $";
    msgEnterWidth   db  "  Enter matrix width:  $";
    msgEnter        db  "  Enter 16 signed numbers's in format(-32768 - +32767): $";
    msgResult       db  "  Result vector: $";                                                                                                                                  
    msgPAUSE        db  "  Press any buttom to continue...$"
    ENDLstr         db  0Ah, 0Dh, '$';
    msgEND          db  "  ================================= Program End ==================================$";

    enter_str   macro   enterAdress;
        
        push    AX;
        push    DX;
        
        mov     AH,     0Ah;
        lea     DX,     enterAdress;  
        int     21h;  
        
        pop     DX;
        pop     AX;
        
    endm
    
    output_str  macro   outputAdress;
        
        push    AX;
        push    DX;
        
        mov     AH,     09h;
        lea     DX,     [outputAdress + 2];
        int     21h;
        
        pop     DX;
        pop     AX;
        
    endm
    
    output_msg  macro   outputAdress, size;
        
        push    AX;
        push    BX;
        push    SI;
        push    DI;
        
        mov     SI,     size;
        lea     DI,     outputAdress + SI + 2;
        mov     SI,     DI;
        lodsb;
        mov     BL,     AL;
        mov     AL,     '$';
        stosb;
        dec     DI;   
           
        mov     AH,     09h;
        lea     DX,     [outputAdress + 2];
        int     21h;
        
        mov     AL,     BL;
        stosb;
        
        pop     DI;
        pop     SI;
        pop     BX;
        pop     AX;
        
    endm        
    
    endl        macro
         
        push    AX;
        push    DX;
                     
        mov     AH,     09h;
        lea     DX,     ENDLstr;
        int     21h; 
        
        pop     DX;
        pop     AX;
        
    endm
    
    exit        macro   endMsg
        
        output_str      endMsg;
        mov     AX,     4c00h;
        int     21h;
        
    endm
    
    pause       macro   pauseMsg
        
        push    AX;
        
        output_str      pauseMsg;
        mov     AH,     01h;
        int     21h;
        
        pop     AX;
        
    endm
    
    clearBuf    macro   strBuf
        
        push    CX;
        push    AX;
        push    DI;
        
        xor     CX,     CX;
        xor     AX,     AX;
        

        mov     CL,     strBuf;
        lea     DI,     strBuf + 1;
        mov     AL,     '$';
            
        rep    stosb;
        
        pop     DI;
        pop     AX;
        pop     CX;
            
     endm;       
            
        
                                                                          
.code

    main:
    
        mov     AX,     @data;
        mov     DS,     AX;
        mov     ES,     AX;
        
        output_str      msgSTART;
        endl;
        
        call    Sidned16MatrixInput;
        
        pause   msgPause;
        endl;
        
        xor     BX,     BX;
        xor     DI,     DI;
        xor     SI,     SI;
        xor     DX,     DX;
        mov     AX,     1;
        xor     CX,     CX;
        mov     Cl,     weidth; 
        lea     BX,     matrix;
        CYCLE_MAIN_1:
        
            xor     DX,     DX;
            mov     AX,     1;
            
            push    CX;
            push    BX;
            xor     CX,     CX;
            mov     CL,     height;
            CYCLE_MAIN_2:    
                
                mov     SI,     word ptr BX;
                call    MUL3216;
                push    AX;
                mov     AL,     weidth;
                shl     AL,     1;
                add     BL,     AL;
                pop     AX;
                
            loop    CYCLE_MAIN_2;
            
            pop     BX;
            pop     CX;      
            inc     BX;
            inc     BX;
            call    ShowSInt32;
            endl;
            
        loop    CYCLE_MAIN_1;
        
        endl;           
        
        pause   msgPause;
        endl;      
    
        exit    msgEND;
        
    

    Signed16Input           proc;              отлажено                                                                                                          
        
        push    BX;
        push    CX;
        push    DI;
        push    SI;
        
        xor     AX,     AX;
        xor     BX,     BX;
        xor     CX,     CX;
        xor     DI,     DI
        mov     SI,     10;
         
        enter_str       NumBuf16;
        mov     CL,     NumSize16;
        dec     CL;       
        
        CYCLE_16SI_1:
        
            mov     BL,     NumMod16 + DI;
            sub     BL,     '0';                  
            add     AL,     BL;
            rcl     AX,     1;
            jb      undefined_16SI;
            rcr     AX,     1;
            inc     DI;
            dec     CX;
            jcxz    exit_CYCLE_16SI_1;
            mul     SI;
            jo      undefined_16SI;
            inc     CX;
            
        loop    CYCLE_16SI_1;   
        exit_CYCLE_16SI_1:
        
        cmp     NumSign16,  '-';
        je      negative_16SI;
        
        cmp     NumSign16,  '+';
        jne     undefined_16SI;                        
        
        jmp     end_16SI;
               
        undefined_16SI:
        xor     AX,     AX;
        jmp     end_16SI; 
        
        negative_16SI:
        neg     AX;
         
        end_16SI:
        pop     SI;
        pop     DI;
        pop     CX;
        pop     BX;
        ret;
                                   
    Signed16Input           endp;
    
    
    Signed16Output          proc;        отлажено
        
        push    AX;
        push    BX;
        push    CX;
        push    DX;
        push    DI;
        push    SI;
        
        cld;
        xor     BX,     BX;
        xor     DI,     DI;
        xor     DX,     DX;
        mov     SI,     10;
        mov     CX,     1;
        mov     byte ptr NumSign16,     '+';
  
        
        rcl     AX,     1;
        jnb     mark_16S0_1;
        
        rcr     AX,     1;
        mov     byte ptr NumSign16,     '-';
        not     AX;
        add     AX,     1;
        jmp     CYCLE_16SO_1;
        
        mark_16S0_1:
        rcr     AX,     1;
        CYCLE_16SO_1:
                
            div     SI;            
            add     DL,     '0';
            push    DX;
            inc     DI;
            xor     DX,     DX;
        
        mov     CX,     AX;
        inc     CX;
        loop    CYCLE_16SO_1; 
        
        mov     CX,     DI;
        inc     CX;
        mov     byte ptr NumSize16,     CL;
     
        dec     CX;
        lea     DI,     NumMod16;
        CYCLE_16SO_2:
            
            pop     AX;
            stosb;
        
        loop    CYCLE_16SO_2;
        
        
        output_str NumBuf16;
        pop     SI;
        pop     DI;
        pop     DX;
        pop     CX;
        pop     BX;
        pop     AX;
        
        ret;
    
    Signed16Output          endp;
    
    
    Sidned16MatrixInput     proc;             отлажено
        
        push    AX;
        push    CX;
        push    DI;
        push    DX;
        push    BX;
        
        xor     AX,     AX;
        mov     AL,     weidth;
        mov     DI,     7;                    
        mul     DI;
        add     AL,     4;
        output_msg      msgHead,    AX;
        endl;
        
        xor     AX,     AX;
        xor     CX,     CX; 
        lea     DI,     matrix;
        mov     CL,     height;
        CYCLE_16SMI_1:
        
            call    Signed16Output;
            mov     BX,     4;
            sub     BL,     NumSize16;       
            output_msg      msgSpace,   BX;
            clearBuf        NumBuf16;
            
            push    CX;
            push    AX;
            mov     CL,     weidth;            
            CYCLE_16SMI_2:
            
                call    Signed16Input;        
                stosw;
                mov     BX,     7;
                sub     BL,     NumSize16;       
                output_msg      msgSpace,   BX;
                clearBuf        NumBuf16;              
                 
            loop CYCLE_16SMI_2;
            pop     AX;
            pop     CX;
            
            inc     AX;
            endl;
                
        loop CYCLE_16SMI_1;
             
        
        pop     BX;
        pop     DX;
        pop     DI;
        pop     AX;
        pop     CX;
        endl;
        ret;
    
    Sidned16MatrixInput     endp;        
       
       
    Sidned16MatrixOutput    proc;        отлажено
        
        push    AX;
        push    CX;
        push    SI;
        push    DX;
        push    BX;
        
        xor     AX,     AX;
        mov     AL,     weidth;
        mov     SI,     7;                    
        mul     SI;
        add     AL,     4;
        output_msg      msgHead,    AX;
        endl;
        
        xor     AX,     AX;
        xor     CX,     CX; 
        lea     SI,     matrix;
        mov     CL,     height;
        CYCLE_16SMO_1:
        
            call    Signed16Output;
            mov     BX,     4;
            sub     BL,     NumSize16;       
            output_msg      msgSpace,   BX;
            clearBuf        NumBuf16;
            
            push    CX;
            push    AX;
            mov     CL,     weidth;            
            CYCLE_16SMO_2: 
            
                lodsw;
                call    Signed16Output;        
                mov     BX,     7;
                sub     BL,     NumSize16;       
                output_msg      msgSpace,   BX;
                clearBuf        NumBuf16;              
                 
            loop CYCLE_16SMO_2;
            pop     AX;
            pop     CX;
            
            inc     AX;
            endl;
           
        loop CYCLE_16SMO_1;
             
        
        pop     BX;
        pop     DX;
        pop     SI;
        pop     AX;
        pop     CX;
        endl;
        ret;
    
    Sidned16MatrixOutput    endp;
                      
                      
    Sign32Change            proc;              отлажено
        
        not     AX;
        not     DX;
        ADD     AX,     1;
        jnb     end_32SC;
        ADD     DX,     1;    
        
        
        end_32SC:
        ret;    
        
    Sign32Change            endp;
           
           
    MUL3216                 proc;            
        
        push    BX;
        push    DI;
        push    SI;
        
        xor     BX,     BX;
        xor     DI,     DI;
        mov     DI,     1;
        
        
        rcl     SI,     1;
        jnb     mark_32MUL16_SignBlock;
        rcr     SI,     1;
        xor     BX,     DI;
        not     SI;
        inc     SI;
        rcl     SI,     1;
        
        mark_32MUL16_SignBlock:
        rcr     SI,     1;
          
        rcl     DX, 1; 
        jnb     body_32MUL16;
        rcr     DX,     1;
        call    Sign32Change;
        xor     BX,     DI;
        rcl     DX,     1;     
        
        body_32MUL16:
        rcr     DX,     1;
        mov     word ptr WordBuffer3,   BX;
        
        mov     DI,     DX;
        mul     SI;
        push    AX;
        mov     AX,     DI;
        
        mov     DI,     DX;
        mul     SI;
        cmp     DX,     0;
        jnz     exit_32MUL16_overflou;
         
        mov     DX,     AX;
        pop     AX;
        ADD     DX,     DI;
        jb      exit_32MUL16_overflou;
        
        mov     BX,     WordBuffer3;
        cmp     BX,     0;
        jz      exit_32MUL16;
        call    Sign32Change;
        
        
        exit_32MUL16:
        pop     SI;
        pop     DI;
        pop     BX;
        ret;
        
        exit_32MUL16_overflou:
        pop     AX;
        pop     SI;
        pop     DI;
        pop     BX;
        xor     DX,     DX;
        xor     AX,     AX;
        ret;
        
    MUL3216                 endp;
       
       
    ShowSINT32              proc;            отлажено
        
        push    AX;
        push    BX;
        push    CX;
        push    DX;
        push    SI;
        push    DI;
        
        
        mov     word ptr WordBuffer3,   0h;           
        rcl     DX,     1; 
        jnb     mark_SSI32_Body;
        
        rcr     DX,     1;
        call    Sign32Change; 
        mov     word ptr WordBuffer3,   1h;
        rcl     DX,     1;
          
        mark_SSI32_Body:
        rcr     DX,     1;
        
        mov     word ptr WordBuffer1,   AX;
        mov     word ptr WordBuffer2,   DX;
 
        mov     BX,     10;      
        mov     DI,     0;
             
        CYCLE_SSI32_NextDigit:
             
            mov     CX,     2;       
            mov     SI,     2;     
            mov     DX,     0;
              
            CYCLE_SSI32_DivBy10:
        
                mov AX,     word ptr WordBuffer1[si];
                div BX;
                mov word ptr WordBuffer1[si],   AX;
                sub SI,     2;  
            
            loop    CYCLE_SSI32_DivBy10;
        
            add     DL,     '0';
            push    DX;              
 
            inc     DI;              
 
            mov     AX,     word ptr WordBuffer1;        
            or      AX,     word ptr WordBuffer2;
            
        jnz     CYCLE_SSI32_NextDigit;        
        
        
        mov     BX,     WordBuffer3;
        cmp     BX,     0;
        jz      mark_SSI32_Positive;
        
        mov     CX,     DI;
        mov     AH,     02h;
        mov     DL,     '-';
        int     21h;
        jmp     CYCLE_SSI32_ShowDigit; 
        
        mark_SSI32_Positive:
        mov     CX,     DI;      
        mov     AH,     02h; 
        mov     DL,     '+';
        int     21h;
            
        CYCLE_SSI32_ShowDigit:
        
            pop DX;              
            int 21h;
                         
        loop    CYCLE_SSI32_ShowDigit;
        
        
        pop     DI;
        pop     SI;
        pop     DX;
        pop     CX;
        pop     BX;
        pop     AX;
        ret;
        
    ShowSInt32              endp;   
    
    end main;        
code    ends    