enum DoormanEndpoints {
  otpSend('doorman/v1/otp/send'),
  otpVerify('doorman/v1/otp/verify'),
  authRefresh('doorman/v1/auth/refresh'),
  authLogout('doorman/v1/auth/logout'),
  authRegister('doorman/v1/auth/register');

  final String path;
  const DoormanEndpoints(this.path);
}
