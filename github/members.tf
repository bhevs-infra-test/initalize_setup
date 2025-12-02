locals {
  super_users = []

  # [MB_GEN 4.0 인원]
  # 관리자 권한
  mb_admins = concat(local.super_users, [
  "ChoiSeungWoo-bhevs"
  ])

  # 개발자 권한
  mb_devs   = concat(local.super_users, [
    "ChoiSeungWoo98"
  ])

  # 외주 권한
  mb_others   = concat(local.super_users, [
    "ChoiseU98"
  ])

  # [FORD_GEN 4.0 인원]
  # 관리자 권한
  ford_admins = concat(local.super_users, [
    "ChoiSeungWoo-bhevs"
  ])

  # 개발자 권한
  ford_devs   = concat(local.super_users, [
    "ChoiSeungWoo98"
  ])

  # 외주 권한
  ford_others = [
    "ChoiseU98"
  ]
}