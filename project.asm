.386
.model flat,stdcall
option casemap:none
    
    include windows.inc
    include user32.inc
    includelib user32.lib
    include kernel32.inc
    includelib kernel32.lib
    include gdi32.inc
    includelib gdi32.lib
    
.data?
    hInstance dd ? ;模块句柄
    hWinMain  dd ?    ;窗口句柄
    
    hBegin      dd ? ;按钮句柄

.data
    dSxarr    dd  100 dup ( ? )   ;x轴
    dSyarr  dd  100 dup ( ? )  ;y轴
    dSize  dd  1;蛇的长度
    
    
    
    
.const
    szClassName  db 'MyClass',0
    szCaptionMain db '汇编版贪吃蛇',0
    szText       db   '写在中间试试',0
    
    szButton    db 'button',0
    szButtonText    db 'begin',0
    
    
.code
    ;绘制线条
_FrameColor proc @hdc
    
    invoke MoveToEx,@hdc,10,10,NULL
    invoke LineTo,@hdc,450,10
    invoke LineTo,@hdc,450,350
    invoke LineTo,@hdc,10,350
    invoke LineTo,@hdc,10,10
        
    ret
_FrameColor endp
;画蛇头
_SnakePro proc @hdc
    local @x
    local @y
    LOCAL @xa
    LOCAL @ya
    ;初始化i
    LOCAL @i
    mov eax,0
    mov @i,eax
    
    
    ;数组地址    
    mov ebx,offset dSxarr
    mov esi,offset dSyarr
    ;长度，不能取地址
    ;mov eax, dSize
    mov eax,dSize
    ;    
    mov edi,0
        
    .while(@i<eax)
    
    ;先将x，y 值取出， 然后各减去9或者+9， 就得到圆的大小；  现在蛇只有1的长度；
    push eax
    
    mov eax,[ebx]
    sub eax,9
    mov @x,eax
    
    add eax,18
    mov @xa,eax
    
    
    mov eax,[esi]
    sub eax,9
    mov @y,eax
    
    add eax,18
    mov @ya,eax
    
    
    add ebx,4
    add esi,4
    ;这里递增地址， 可以考虑 进栈保存
    
    invoke Ellipse,@hdc,@x,@y,@xa,@ya
    inc @i    
    
    pop eax
    .endw
    
    ret

_SnakePro endp


    
_ProcWinMain  proc uses ebx edi esi,hWnd,uMsg,wParam,lParam
local @stPs:PAINTSTRUCT

local @hDc
    mov eax,uMsg
    
    .if  eax==WM_PAINT
        invoke BeginPaint,hWnd,addr @stPs
        mov @hDc,eax
        
    
        ;invoke TextOut,@hDc,10,10,offset szText,sizeof szText
        
        invoke _FrameColor,@hDc   ;绘制线条
        
        invoke _SnakePro,@hDc ;绘制蛇
        
        invoke EndPaint,hWnd,addr @stPs
    .elseif eax==WM_COMMAND
        mov eax,lParam
        .if eax==hBegin
            mov eax,wParam
            .if eax==BS_PUSHBUTTON
                invoke MessageBox,0,0,0,0
            .endif
            
        .endif
    .elseif eax==WM_KEYDOWN
        mov eax,wParam
        .if eax==38
        ;up
            mov ebx,offset dSyarr
            mov eax,10
            sub [ebx],eax
            
        .elseif eax==39
            mov ebx,offset dSxarr
            mov eax,10
            add [ebx],eax
        
        .elseif eax==40
            mov ebx,offset dSyarr
            mov eax,10
            add [ebx],eax
        
        .elseif eax==37
        ;left    
            mov ebx,offset dSxarr
            mov eax,10
            sub [ebx],eax
        .endif
        invoke InvalidateRect,hWinMain,NULL,TRUE
            
    .elseif eax==WM_CLOSE
        
        invoke DestroyWindow,hWinMain
        
        invoke PostQuitMessage,NULL
        
    .else
        invoke DefWindowProc,hWnd,uMsg,wParam,lParam
        ret
    .endif
    
    xor eax,eax
    ret
_ProcWinMain  endp
    
_WinMain   proc
local @stWndClass:WNDCLASSEX
local @stMsg:MSG
    
    invoke GetModuleHandle,NULL
    mov hInstance,eax
    invoke RtlZeroMemory,addr @stWndClass,sizeof @stWndClass
    invoke LoadCursor,0,IDC_ARROW
    mov @stWndClass.hCursor,eax
    push hInstance
    pop @stWndClass.hInstance
    mov @stWndClass.cbSize,sizeof WNDCLASSEX
    mov @stWndClass.style,CS_HREDRAW or CS_VREDRAW
    mov @stWndClass.lpfnWndProc,offset _ProcWinMain
    mov @stWndClass.hbrBackground,COLOR_WINDOW+1
    mov @stWndClass.lpszClassName,offset szClassName
    invoke RegisterClassEx,addr @stWndClass
    
    
    ;   初始化；
    mov ebx,offset dSxarr
    
    mov eax,50
    
    mov [ebx],eax
    
    mov ebx,offset dSyarr
    
    mov eax,50
    
    mov [ebx],eax
    
    
    invoke CreateWindowEx,WS_EX_CLIENTEDGE,\
    offset szClassName,offset szCaptionMain,
    WS_OVERLAPPEDWINDOW,
    100,100,600,400,
    NULL,NULL,hInstance,NULL
    mov hWinMain,eax
    invoke ShowWindow,hWinMain,SW_SHOWNORMAL
    invoke UpdateWindow,hWinMain
    
    ;开始按钮    
    invoke CreateWindowEx,WS_EX_CLIENTEDGE,\
    offset szButton,offset szButtonText,WS_CHILD or WS_VISIBLE or WS_BORDER,500,10,70,35,hWinMain,NULL,NULL,NULL
    mov hBegin,eax
    
    
    ;这里加入    
    .while TRUE
        invoke GetMessage,addr @stMsg,NULL,0,0
        .break .if eax == 0
        invoke TranslateMessage,addr @stMsg
        invoke DispatchMessage,addr @stMsg
    .endw
    ret
_WinMain  endp
start:
    call _WinMain
    invoke ExitProcess,NULL
end start