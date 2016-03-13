; ModuleID = 'acqrel.c'
target datalayout = "e-p:64:64:64-i1:8:8-i8:8:8-i16:16:16-i32:32:32-i64:64:64-f32:32:32-f64:64:64-v64:64:64-v128:128:128-a0:0:64-s0:64:64-f80:128:128-n8:16:32:64-S128"
target triple = "x86_64-pc-linux-gnu"

@R = common global i32 0, align 4
@A = common global i32 0, align 4

; Function Attrs: nounwind uwtable
define void @init() #0 {
  store volatile i32 0, i32* @R, align 4
  store volatile i32 0, i32* @A, align 4
  ret void
}

; Function Attrs: nounwind uwtable
define i32 @main() #0 {
  %1 = alloca i32, align 4
  %n = alloca i32, align 4
  %x = alloca i32, align 4
  store i32 0, i32* %1
  call void @init()
  store volatile i32 0, i32* %n, align 4
  br label %2

; <label>:2                                       ; preds = %13, %0
  %3 = call i32 (...)* @__VERIFIER_nondet_int()
  %4 = icmp ne i32 %3, 0
  br i1 %4, label %5, label %14

; <label>:5                                       ; preds = %2
  store volatile i32 1, i32* @A, align 4
  store volatile i32 0, i32* @A, align 4
  %6 = call i32 (...)* @__VERIFIER_nondet_int()
  store volatile i32 %6, i32* %n, align 4
  br label %7

; <label>:7                                       ; preds = %10, %5
  %8 = load volatile i32* %n, align 4
  %9 = icmp sgt i32 %8, 0
  br i1 %9, label %10, label %13

; <label>:10                                      ; preds = %7
  %11 = load volatile i32* %n, align 4
  %12 = add nsw i32 %11, -1
  store volatile i32 %12, i32* %n, align 4
  br label %7

; <label>:13                                      ; preds = %7
  store volatile i32 1, i32* @R, align 4
  store volatile i32 0, i32* @R, align 4
  br label %2

; <label>:14                                      ; preds = %2
  br label %15

; <label>:15                                      ; preds = %14, %15
  %16 = load volatile i32* %x, align 4
  store volatile i32 %16, i32* %x, align 4
  br label %15
                                                  ; No predecessors!
  %18 = load i32* %1
  ret i32 %18
}

declare i32 @__VERIFIER_nondet_int(...) #1

attributes #0 = { nounwind uwtable "less-precise-fpmad"="false" "no-frame-pointer-elim"="true" "no-frame-pointer-elim-non-leaf" "no-infs-fp-math"="false" "no-nans-fp-math"="false" "stack-protector-buffer-size"="8" "unsafe-fp-math"="false" "use-soft-float"="false" }
attributes #1 = { "less-precise-fpmad"="false" "no-frame-pointer-elim"="true" "no-frame-pointer-elim-non-leaf" "no-infs-fp-math"="false" "no-nans-fp-math"="false" "stack-protector-buffer-size"="8" "unsafe-fp-math"="false" "use-soft-float"="false" }

!llvm.ident = !{!0}

!0 = metadata !{metadata !"Ubuntu clang version 3.4-1ubuntu3 (tags/RELEASE_34/final) (based on LLVM 3.4)"}
