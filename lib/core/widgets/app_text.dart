import 'package:flutter/material.dart';

import '../theme/app_text_style.dart';

class AppText extends StatelessWidget {
  const AppText.titleLarge(
    this.text, {
    super.key,
    this.color,
    this.fontSize,
    this.fontWeight,
    this.height,
    this.textAlign,
    this.maxLines,
    this.overflow,
  }) : style = AppTextStyle.titleLarge;

  const AppText.titleMedium(
    this.text, {
    super.key,
    this.color,
    this.fontSize,
    this.fontWeight,
    this.height,
    this.textAlign,
    this.maxLines,
    this.overflow,
  }) : style = AppTextStyle.titleMedium;

  const AppText.titleSmall(
    this.text, {
    super.key,
    this.color,
    this.fontSize,
    this.fontWeight,
    this.height,
    this.textAlign,
    this.maxLines,
    this.overflow,
  }) : style = AppTextStyle.titleSmall;

  const AppText.subTitle(
    this.text, {
    super.key,
    this.color,
    this.fontSize,
    this.fontWeight,
    this.height,
    this.textAlign,
    this.maxLines,
    this.overflow,
  }) : style = AppTextStyle.subTitle;

  const AppText.bodyLarge(
    this.text, {
    super.key,
    this.color,
    this.fontSize,
    this.fontWeight,
    this.height,
    this.textAlign,
    this.maxLines,
    this.overflow,
  }) : style = AppTextStyle.bodyLarge;

  const AppText.bodyMedium(
    this.text, {
    super.key,
    this.color,
    this.fontSize,
    this.fontWeight,
    this.height,
    this.textAlign,
    this.maxLines,
    this.overflow,
  }) : style = AppTextStyle.bodyMedium;

  const AppText.bodySmall(
    this.text, {
    super.key,
    this.color,
    this.fontSize,
    this.fontWeight,
    this.height,
    this.textAlign,
    this.maxLines,
    this.overflow,
  }) : style = AppTextStyle.bodySmall;

  const AppText.button(
    this.text, {
    super.key,
    this.color,
    this.fontSize,
    this.fontWeight,
    this.height,
    this.textAlign,
    this.maxLines,
    this.overflow,
  }) : style = AppTextStyle.button;

  const AppText.hint(
    this.text, {
    super.key,
    this.color,
    this.fontSize,
    this.fontWeight,
    this.height,
    this.textAlign,
    this.maxLines,
    this.overflow,
  }) : style = AppTextStyle.hint;

  const AppText.caption(
    this.text, {
    super.key,
    this.color,
    this.fontSize,
    this.fontWeight,
    this.height,
    this.textAlign,
    this.maxLines,
    this.overflow,
  }) : style = AppTextStyle.caption;

  const AppText.authBrand(
    this.text, {
    super.key,
    this.color,
    this.fontSize,
    this.fontWeight,
    this.height,
    this.textAlign,
    this.maxLines,
    this.overflow,
  }) : style = AppTextStyle.authBrand;

  const AppText.authHeroTitle(
    this.text, {
    super.key,
    this.color,
    this.fontSize,
    this.fontWeight,
    this.height,
    this.textAlign,
    this.maxLines,
    this.overflow,
  }) : style = AppTextStyle.authHeroTitle;

  const AppText.authHeroSubtitle(
    this.text, {
    super.key,
    this.color,
    this.fontSize,
    this.fontWeight,
    this.height,
    this.textAlign,
    this.maxLines,
    this.overflow,
  }) : style = AppTextStyle.authHeroSubtitle;

  const AppText.authScreenTitle(
    this.text, {
    super.key,
    this.color,
    this.fontSize,
    this.fontWeight,
    this.height,
    this.textAlign,
    this.maxLines,
    this.overflow,
  }) : style = AppTextStyle.authScreenTitle;

  final String text;
  final TextStyle style;
  final Color? color;
  final double? fontSize;
  final FontWeight? fontWeight;
  final double? height;
  final TextAlign? textAlign;
  final int? maxLines;
  final TextOverflow? overflow;

  @override
  Widget build(BuildContext context) {
    return Text(
      text,
      textAlign: textAlign,
      maxLines: maxLines,
      overflow: overflow,
      style: style.copyWith(
        color: color,
        fontSize: fontSize,
        fontWeight: fontWeight,
        height: height,
      ),
    );
  }
}
