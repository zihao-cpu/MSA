
# 🧠 Multiperturbation Shapley Value Analysis (MSA) 全面笔记

---

## 📌 1. MSA 的核心目标

> 利用 Shapley 值，评估每个脑区对行为表现（如 FMA）的“边际贡献”，识别关键功能脑区。

---

## 📊 2. 数据输入结构

```matlab
xy = [X, y];
```

- `X`: 每一行为一个受试者，列为各个脑区损伤程度（Z 值，0~1）
- `y`: 行为分数（如 FMA），数值越高功能越好
- `X_i = 1 - Z_i`：脑区功能保留度

---

## ⚙️ 3. 核心函数入口

```matlab
[SV, Calib, coal, Bset, Lset] = PerformMSA(xy, pdepth, nBS, alpha, TOP);
```

- `pdepth`: 最大扰动组合大小（如设置为 5，评估1~5个脑区组合）
- `nBS`: bootstrap 次数（>0 触发统计推断）
- `TOP`: 健康被试行为评分上限（如 FMA=66）

---

## 🧠 4. Shapley 值的定义与近似

Shapley 值原始定义（合作博弈论）：

$$
\phi_i = \sum_{S \subseteq N \setminus \{i\}} \frac{|S|!(|N|-|S|-1)!}{|N|!} \cdot (v(S \cup \{i\}) - v(S))
$$

由于组合数指数级增长，MSA 使用 **Potentials method** 近似：

$$
\phi_i \approx \sum_{k=1}^{pdepth} \frac{1}{k} \cdot \left( \mathbb{E}[v_k(i)] - \mathbb{E}[v_k] \right) + \text{offset}
$$

- $\mathbb{E}[v_k(i)]$: 所有大小为 k 且包含 i 的组合的平均预测值  
- $\mathbb{E}[v_k]$: 所有大小为 k 的组合的平均预测值

---

## 🧪 5. 行为预测目标函数（目标函数）

默认预测器为：

$$v(S) = \sum_j w_j^{(S)} \cdot y_j, \quad w_j = \exp(-b \cdot d_j)$$

- `ApplyPredictor` 函数实现核加权平均
- `b_param`: 控制距离衰减，默认 15（越大越局部）

---

## 📈 6. Shapley 值计算代码位置

在 `Compute_ShapleyVector_Bound.m` 中核心片段：

```matlab
VVest(nR, region) = mean(Vest{nR}(indices));       % E[v_k(i)]
meanest(nR) = mean(pre1SHest(nR,:));               % E[v_k]
SHest(j,:) = TOP/m + pre1SHest(j,:) - meanest(j);  % 最终 Shapley 值
```

---

## 📊 7. 统计显著性检验

使用 bootstrap 或 leave-one-out 生成：

- `pvalestmix`: 每个脑区的 p 值
- `pvalestFDRmix`: FDR 校正后的 p 值
- `CIcalibmixSHAPL`: 置信区间 + SV 值，便于绘图

显著性判断方法：
- p < 0.05
- 置信区间不跨 0

---

## 📌 8. 可视化函数 `plotSV`

```matlab
plotSV(Bset, calib, fdr_flag, large_only_flag, alpha, RegionNames)
```

- 显示 SV、误差条、显著标记 `*`、未校正显著性 `o`

---

## 🔍 9. 分析某脑区与其他脑区的交互

查找含某脑区 i 的所有组合：

```matlab
idx = find(any(coal.Coal{p} == i, 2));
```

统计与其共同出现频率，构建交互热图或网络图。

---

## ✅ 总结

MSA 用近似 Shapley 值方法，在临床行为数据中定位关键脑区：

- 目标函数：v(S) 为组合 S 的行为预测值
- Shapley 值：期望边际贡献
- Potentials method：高效估算
- Bootstrap/LOO：推断稳定性和显著性
