# Spec: Student Access Control in Course Detail

**Date:** 2026-04-24  
**Branch:** feature/test-flow

## Problem

In mock mode, students can view all students' test results and delete tests from the course detail screen. Root cause: `CourseDatasourceMock.getCourseDetail` hardcodes `isTeacher: true` for all users, so students receive teacher UI.

The routing and UI logic are already correct — `CourseDetailScreen` reads `course.isTeacher` to decide navigation target, and `TestSessionResultsScreen` has a guard that shows "Нет доступа" for non-teachers. The issues are (1) mock returning wrong data and (2) no client-side role validation.

## Intended Behaviour

| Role | Taps test in module | Navigates to | Sees |
|------|---------------------|-------------|------|
| Teacher | any test | `/test/{id}/results` | All students' attempts + delete button |
| Student | not started / in progress | `/test/{id}` | Preview → Start / Resume |
| Student | completed | `/test/{id}` | Preview → "Посмотреть результат" → own attempt review |

A student can never navigate to `/test/{id}/results`. Even if the API mistakenly returns `is_teacher: true`, the client overrides it using the stored role.

## Solution

Two-layer fix:

**Layer 1 — Fix mock**: Make `CourseDatasourceMock` role-aware by reading from `ProfileStorage` (same pattern as `UserDatasourceMock`).

**Layer 2 — Client-side guard**: `CourseDetailBloc` reads `ProfileStorage` and overrides `isTeacher`:
```
effectiveIsTeacher = apiIsTeacher && profileStorage.getRole() == 'teacher'
```
This ensures teacher UI is never shown to a user in student mode, even if the API returns an incorrect value.

## Changes

| File | Change |
|------|--------|
| `edium/lib/data/datasources/course/course_datasource_mock.dart` | Add `ProfileStorage` constructor param; replace `isTeacher: true` → `isTeacher: _profileStorage.getRole() == 'teacher'` |
| `edium/lib/core/di/injection.dart` | Pass `getIt<ProfileStorage>()` to `CourseDatasourceMock()` |
| `edium/lib/presentation/teacher/course_detail/bloc/course_detail_bloc.dart` | Add `ProfileStorage` field; after loading `CourseDetail`, override: `course.copyWith(isTeacher: course.isTeacher && _profileStorage.getRole() == 'teacher')` |
| `edium/lib/presentation/teacher/course_detail/course_detail_screen.dart` | Pass `profileStorage: getIt<ProfileStorage>()` when creating `CourseDetailBloc` |

## Out of Scope

- No routing changes
- No UI changes (guards already exist)
- No new screens or models
- Real backend `CourseDetailImpl` already returns correct `is_teacher` from API; Layer 2 is the safety net
