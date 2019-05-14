# UIControl-Limit
限制按钮短时间内重复点击
### 使用:
```
UIButton *limitBtn = [UIButton new];
[limitBtn addTarget:self action:@selector(praise:) forControlEvents:(UIControlEventTouchUpInside)];
limitBtn.limitEventInterval = 1.5f;
```
