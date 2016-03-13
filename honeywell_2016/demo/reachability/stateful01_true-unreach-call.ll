; ModuleID = 'stateful01_true-unreach-call.i'
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
define i8* @thread1(i8* %arg) #0 {
  %1 = alloca i8*, align 8
  %2 = alloca i8*, align 8
  store i8* %arg, i8** %2, align 8
  %3 = call i32 @pthread_mutex_lock(%union.pthread_mutex_t* @ma) #3
  %4 = load i32* @data1, align 4
  %5 = add nsw i32 %4, 1
  store i32 %5, i32* @data1, align 4
  %6 = call i32 @pthread_mutex_unlock(%union.pthread_mutex_t* @ma) #3
  %7 = call i32 @pthread_mutex_lock(%union.pthread_mutex_t* @ma) #3
  %8 = load i32* @data2, align 4
  %9 = add nsw i32 %8, 1
  store i32 %9, i32* @data2, align 4
  %10 = call i32 @pthread_mutex_unlock(%union.pthread_mutex_t* @ma) #3
  %11 = load i8** %1
  ret i8* %11
}

; Function Attrs: nounwind
declare i32 @pthread_mutex_lock(%union.pthread_mutex_t*) #1

; Function Attrs: nounwind
declare i32 @pthread_mutex_unlock(%union.pthread_mutex_t*) #1

; Function Attrs: nounwind uwtable
define i8* @thread2(i8* %arg) #0 {
  %1 = alloca i8*, align 8
  %2 = alloca i8*, align 8
  store i8* %arg, i8** %2, align 8
  %3 = call i32 @pthread_mutex_lock(%union.pthread_mutex_t* @ma) #3
  %4 = load i32* @data1, align 4
  %5 = add nsw i32 %4, 5
  store i32 %5, i32* @data1, align 4
  %6 = call i32 @pthread_mutex_unlock(%union.pthread_mutex_t* @ma) #3
  %7 = call i32 @pthread_mutex_lock(%union.pthread_mutex_t* @ma) #3
  %8 = load i32* @data2, align 4
  %9 = sub nsw i32 %8, 6
  store i32 %9, i32* @data2, align 4
  %10 = call i32 @pthread_mutex_unlock(%union.pthread_mutex_t* @ma) #3
  %11 = load i8** %1
  ret i8* %11
}

; Function Attrs: nounwind uwtable
define i32 @main() #0 {
  %1 = alloca i32, align 4
  %t1 = alloca i64, align 8
  %t2 = alloca i64, align 8
  store i32 0, i32* %1
  %2 = call i32 @pthread_mutex_init(%union.pthread_mutex_t* @ma, %union.pthread_mutexattr_t* null) #3
  %3 = call i32 @pthread_mutex_init(%union.pthread_mutex_t* @mb, %union.pthread_mutexattr_t* null) #3
  store i32 10, i32* @data1, align 4
  store i32 10, i32* @data2, align 4
  %4 = call i32 @pthread_create(i64* %t1, %union.pthread_attr_t* null, i8* (i8*)* @thread1, i8* null) #3
  %5 = call i32 @pthread_create(i64* %t2, %union.pthread_attr_t* null, i8* (i8*)* @thread2, i8* null) #3
  %6 = load i64* %t1, align 8
  %7 = call i32 @pthread_join(i64 %6, i8** null)
  %8 = load i64* %t2, align 8
  %9 = call i32 @pthread_join(i64 %8, i8** null)
  %10 = load i32* @data1, align 4
  %11 = icmp eq i32 %10, 16
  br i1 %11, label %12, label %15

; <label>:12                                      ; preds = %0
  %13 = load i32* @data2, align 4
  %14 = icmp eq i32 %13, 5
  br label %15

; <label>:15                                      ; preds = %12, %0
  %16 = phi i1 [ false, %0 ], [ %14, %12 ]
  %17 = zext i1 %16 to i32
  %18 = call i32 (i32, ...)* bitcast (i32 (...)* @assert to i32 (i32, ...)*)(i32 %17)
  ret i32 0
}

; Function Attrs: nounwind
declare i32 @pthread_mutex_init(%union.pthread_mutex_t*, %union.pthread_mutexattr_t*) #1

; Function Attrs: nounwind
declare i32 @pthread_create(i64*, %union.pthread_attr_t*, i8* (i8*)*, i8*) #1

declare i32 @pthread_join(i64, i8**) #2

declare i32 @assert(...) #2

attributes #0 = { nounwind uwtable "less-precise-fpmad"="false" "no-frame-pointer-elim"="true" "no-frame-pointer-elim-non-leaf" "no-infs-fp-math"="false" "no-nans-fp-math"="false" "stack-protector-buffer-size"="8" "unsafe-fp-math"="false" "use-soft-float"="false" }
attributes #1 = { nounwind "less-precise-fpmad"="false" "no-frame-pointer-elim"="true" "no-frame-pointer-elim-non-leaf" "no-infs-fp-math"="false" "no-nans-fp-math"="false" "stack-protector-buffer-size"="8" "unsafe-fp-math"="false" "use-soft-float"="false" }
attributes #2 = { "less-precise-fpmad"="false" "no-frame-pointer-elim"="true" "no-frame-pointer-elim-non-leaf" "no-infs-fp-math"="false" "no-nans-fp-math"="false" "stack-protector-buffer-size"="8" "unsafe-fp-math"="false" "use-soft-float"="false" }
attributes #3 = { nounwind }

!llvm.ident = !{!0}

!0 = metadata !{metadata !"Ubuntu clang version 3.4-1ubuntu3 (tags/RELEASE_34/final) (based on LLVM 3.4)"}
