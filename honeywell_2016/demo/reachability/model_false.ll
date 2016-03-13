; ModuleID = 'stateful01_false-unreach-call.i'
target datalayout = "e-p:64:64:64-i1:8:8-i8:8:8-i16:16:16-i32:32:32-i64:64:64-f32:32:32-f64:64:64-v64:64:64-v128:128:128-a0:0:64-s0:64:64-f80:128:128-n8:16:32:64-S128"
target triple = "x86_64-pc-linux-gnu"

%union.pthread_mutex_t = type { %struct.__pthread_mutex_s }
%struct.__pthread_mutex_s = type { i32, i32, i32, i32, i32, %union.anon }
%union.anon = type { %struct.__pthread_internal_slist }
%struct.__pthread_internal_slist = type { %struct.__pthread_internal_slist* }
%union.pthread_mutexattr_t = type { i64 }
%union.pthread_attr_t = type { i64, [32 x i8] }

@ma = common global %union.pthread_mutex_t zeroinitializer, align 8
@data1 = common global i32 0, align 4
@data2 = common global i32 0, align 4
@mb = common global %union.pthread_mutex_t zeroinitializer, align 8

; Function Attrs: nounwind uwtable
define noalias i8* @thread1(i8* nocapture readnone %arg) #0 {
  %1 = tail call i32 @pthread_mutex_lock(%union.pthread_mutex_t* @ma) #3
  %2 = load volatile i32* @data1, align 4, !tbaa !1
  %3 = add nsw i32 %2, 1
  store volatile i32 %3, i32* @data1, align 4, !tbaa !1
  %4 = tail call i32 @pthread_mutex_unlock(%union.pthread_mutex_t* @ma) #3
  %5 = tail call i32 @pthread_mutex_lock(%union.pthread_mutex_t* @ma) #3
  %6 = load volatile i32* @data2, align 4, !tbaa !1
  %7 = add nsw i32 %6, 1
  store volatile i32 %7, i32* @data2, align 4, !tbaa !1
  %8 = tail call i32 @pthread_mutex_unlock(%union.pthread_mutex_t* @ma) #3
  ret i8* undef
}

; Function Attrs: nounwind
declare i32 @pthread_mutex_lock(%union.pthread_mutex_t*) #1

; Function Attrs: nounwind
declare i32 @pthread_mutex_unlock(%union.pthread_mutex_t*) #1

; Function Attrs: nounwind uwtable
define noalias i8* @thread2(i8* nocapture readnone %arg) #0 {
  %1 = load volatile i32* @data1, align 4, !tbaa !1
  %2 = add nsw i32 %1, 5
  store volatile i32 %2, i32* @data1, align 4, !tbaa !1
  br label %.critedge

.critedge:                                        ; preds = %.critedge, %0
  %3 = tail call i32 (...)* @__VERIFIER_nondet_int() #3
  %4 = icmp ugt i32 %3, 42
  br i1 %4, label %.critedge, label %5

; <label>:5                                       ; preds = %.critedge
  %6 = tail call i32 @pthread_mutex_lock(%union.pthread_mutex_t* @ma) #3
  %7 = load volatile i32* @data2, align 4, !tbaa !1
  %8 = add nsw i32 %7, %3
  store volatile i32 %8, i32* @data2, align 4, !tbaa !1
  %9 = tail call i32 @pthread_mutex_unlock(%union.pthread_mutex_t* @ma) #3
  ret i8* undef
}

declare i32 @__VERIFIER_nondet_int(...) #2

; Function Attrs: nounwind uwtable
define i32 @main() #0 {
  %t1 = alloca i64, align 8
  %t2 = alloca i64, align 8
  %1 = call i32 @pthread_mutex_init(%union.pthread_mutex_t* @ma, %union.pthread_mutexattr_t* null) #3
  %2 = call i32 @pthread_mutex_init(%union.pthread_mutex_t* @mb, %union.pthread_mutexattr_t* null) #3
  store volatile i32 10, i32* @data1, align 4, !tbaa !1
  store volatile i32 10, i32* @data2, align 4, !tbaa !1
  %3 = call i32 @pthread_create(i64* %t1, %union.pthread_attr_t* null, i8* (i8*)* @thread1, i8* null) #3
  %4 = call i32 @pthread_create(i64* %t2, %union.pthread_attr_t* null, i8* (i8*)* @thread2, i8* null) #3
  %5 = load i64* %t1, align 8, !tbaa !5
  %6 = call i32 @pthread_join(i64 %5, i8** null) #3
  %7 = load i64* %t2, align 8, !tbaa !5
  %8 = call i32 @pthread_join(i64 %7, i8** null) #3
  %9 = load volatile i32* @data1, align 4, !tbaa !1
  %10 = icmp eq i32 %9, 16
  br i1 %10, label %11, label %14

; <label>:11                                      ; preds = %0
  %12 = load volatile i32* @data2, align 4, !tbaa !1
  %13 = icmp sgt i32 %12, -1
  br label %14

; <label>:14                                      ; preds = %11, %0
  %15 = phi i1 [ false, %0 ], [ %13, %11 ]
  %16 = zext i1 %15 to i32
  %17 = call i32 (i32, ...)* bitcast (i32 (...)* @assert to i32 (i32, ...)*)(i32 %16) #3
  ret i32 0
}

; Function Attrs: nounwind
declare i32 @pthread_mutex_init(%union.pthread_mutex_t*, %union.pthread_mutexattr_t*) #1

; Function Attrs: nounwind
declare i32 @pthread_create(i64*, %union.pthread_attr_t*, i8* (i8*)*, i8*) #1

declare i32 @pthread_join(i64, i8**) #2

declare i32 @assert(...) #2

attributes #0 = { nounwind uwtable "less-precise-fpmad"="false" "no-frame-pointer-elim"="false" "no-infs-fp-math"="false" "no-nans-fp-math"="false" "stack-protector-buffer-size"="8" "unsafe-fp-math"="false" "use-soft-float"="false" }
attributes #1 = { nounwind "less-precise-fpmad"="false" "no-frame-pointer-elim"="false" "no-infs-fp-math"="false" "no-nans-fp-math"="false" "stack-protector-buffer-size"="8" "unsafe-fp-math"="false" "use-soft-float"="false" }
attributes #2 = { "less-precise-fpmad"="false" "no-frame-pointer-elim"="false" "no-infs-fp-math"="false" "no-nans-fp-math"="false" "stack-protector-buffer-size"="8" "unsafe-fp-math"="false" "use-soft-float"="false" }
attributes #3 = { nounwind }

!llvm.ident = !{!0}

!0 = metadata !{metadata !"Ubuntu clang version 3.4-1ubuntu3 (tags/RELEASE_34/final) (based on LLVM 3.4)"}
!1 = metadata !{metadata !2, metadata !2, i64 0}
!2 = metadata !{metadata !"int", metadata !3, i64 0}
!3 = metadata !{metadata !"omnipotent char", metadata !4, i64 0}
!4 = metadata !{metadata !"Simple C/C++ TBAA"}
!5 = metadata !{metadata !6, metadata !6, i64 0}
!6 = metadata !{metadata !"long", metadata !3, i64 0}
