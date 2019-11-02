;set this to bash so you can use gdbtool + 程序名
; gdbtool () { emacs -nw --eval "(gdb \"gdb --annotate=3 -i=mi $*\")";}

(global-set-key [M-left] 'windmove-left)
(global-set-key [M-right] 'windmove-right)
(global-set-key [M-up] 'windmove-up)
(global-set-key [M-down] 'windmove-down)

(global-set-key [f5] 'gud-run)
(global-set-key [S-f5] 'gud-cont)
(global-set-key [f6] 'gud-jump)
(global-set-key [S-f6] 'gud-print)
(global-set-key [f7] 'gud-step)
(global-set-key [f8] 'gud-next)
(global-set-key [S-f7] 'gud-stepi)
(global-set-key [S-f8] 'gud-nexti)
(global-set-key [f9] 'gud-break)
(global-set-key [S-f9] 'gud-remove)
(global-set-key [f10] 'gud-until)
(global-set-key [S-f10] 'gud-finish)

(global-set-key [f4] 'gud-up)
(global-set-key [S-f4] 'gud-down)

(setq gdb-many-windows t)

(require 'xt-mouse)
(xterm-mouse-mode)
(require 'mouse)
(xterm-mouse-mode t)
(defun track-mouse (e))

(setq mouse-wheel-follow-mouse 't)

(defvar alternating-scroll-down-next t)
(defvar alternating-scroll-up-next t)

(defun alternating-scroll-down-line ()
  (interactive "@")
    (when alternating-scroll-down-next
      (scroll-down-line))
    (setq alternating-scroll-down-next (not alternating-scroll-down-next)))

(defun alternating-scroll-up-line ()
  (interactive "@")
    (when alternating-scroll-up-next
      (scroll-up-line))
    (setq alternating-scroll-up-next (not alternating-scroll-up-next)))

(global-set-key (kbd "<mouse-4>") 'alternating-scroll-down-line)
(global-set-key (kbd "<mouse-5>") 'alternating-scroll-up-line)

;;启动gdb-many-windows时加载的钩子函数，改变many-windows的默认布局，这个钩子函数不能勾在gdb-setup-windows，因为此时assamble-buffer还没完成初始化，不能set到window  
(defadvice gdb-frame-handler-1 (after activate)  
  (if gdb-use-separate-io-buffer  
      (advice_separate_io)  
    (advice_no_separate_io)))  
  
;;生成没有单独IO窗口的gdb布局  
(defun advice_no_separate_io()  
;;默认的生成gdb-assembler-buffer的函数本身也会设计调用gdb-frame-handler-1，加入此条件发生避免无限递归调用  
  (if (not (gdb-get-buffer 'gdb-assembler-buffer))  
      (progn  
    (shrink-window-horizontally ( / (window-width) 3))  
  
    (other-window 1)  
    (split-window-horizontally)  
  
    (other-window 1)  
    (gdb-set-window-buffer (gdb-stack-buffer-name))  
  
    (other-window 1)  
    (split-window-horizontally)  
  
    (other-window 1)  
    (gdb-set-window-buffer (gdb-get-buffer-create 'gdb-assembler-buffer))  
  
    (split-window-horizontally  (/ ( * (window-width) 2) 3))  
  
    (other-window 1)  
    (gdb-set-window-buffer (gdb-get-buffer-create 'gdb-registers-buffer))  
  
    (other-window 1)  
    (toggle-current-window-dedication)  
    (gdb-set-window-buffer (gdb-get-buffer-create 'gdb-memory-buffer))  
    (toggle-current-window-dedication)  
  
    (other-window 2)  
    )))  
  
;;生成有单独IO窗口的gdb布局  
(defun advice_separate_io()  
;;默认的生成gdb-assembler-buffer的函数本身也会设计调用gdb-frame-handler-1，加入此条件发生避免无限递归调用  
  (if (not (gdb-get-buffer 'gdb-assembler-buffer))  
      (progn  
    (split-window-horizontally)  
    (enlarge-window-horizontally ( / (window-width) 3))  
    (other-window 1)  
  
    ;;此处不能使用(gdb-set-window-buffer (gdb-get-buffer-create 'gdb-inferior-io))代替，  
    ;;因为在打开gdb-use-separate-io-buffer的状态时，它还会额外调用一些函数将gdb的input，output定位到该buffer  
    (gdb-set-window-buffer (gdb-inferior-io-name))  
  
    (other-window 1)  
    (split-window-horizontally)  
  
    (other-window 1)  
    (gdb-set-window-buffer (gdb-stack-buffer-name))  
  
    (other-window 1)  
  
    (other-window 1)  
    (toggle-current-window-dedication)  
    (gdb-set-window-buffer (gdb-get-buffer-create 'gdb-assembler-buffer))  
    (toggle-current-window-dedication)  
  
    (split-window-horizontally  (/ ( * (window-width) 2) 3))  
  
    (other-window 1)  
    (gdb-set-window-buffer (gdb-get-buffer-create 'gdb-registers-buffer))  
  
    (other-window 1)  
    (toggle-current-window-dedication)  
    (gdb-set-window-buffer (gdb-get-buffer-create 'gdb-memory-buffer))  
    (toggle-current-window-dedication)  
  
    (other-window 2)  
    )))  
