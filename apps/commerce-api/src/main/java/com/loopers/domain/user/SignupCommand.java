package com.loopers.domain.user;

public record SignupCommand(
    String loginId,
    String password,
    String name,
    String birthday,
    String email
) {}
