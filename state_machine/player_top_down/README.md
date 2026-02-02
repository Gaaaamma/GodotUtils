# Player StateMachine + AnimationTree 使用說明

本專案使用 **「程式狀態機（State / StateMachine）」** 搭配 **AnimationTree（僅負責 BlendSpace2D）」** 的架構。

---

## 核心設計理念

- **狀態切換完全由程式控制**
  - 所有動畫狀態切換都透過  
    `AnimationNodeStateMachinePlayback.travel(state_name)`
  - AnimationTree **不負責自動轉換、不寫 condition、不拉 transition 線**

- **AnimationTree 的唯一責任**
  - 提供 `BlendSpace2D`
  - 接收程式設定的 `blend_position`
  - 不包含邏輯判斷

- **State = 行為 + 動畫狀態的單一來源**
  - 每一個 State：
    - 控制角色行為（輸入、移動、速度）
    - 控制動畫狀態（呼叫 `travel`）
    - 決定何時轉移到其他 State

---

## 節點結構（必要）

Player 節點必須長成以下結構：

```
Player (CharacterBody2D)
├─ Sprite2D
├─ AnimationPlayer
├─ AnimationTree
└─ StateMachine
   ├─ IdleState
   └─ WalkState
```

> ⚠️ StateMachine、所有 State **必須是 Player 的子節點**

---

## AnimationTree 必要設定

### 1️⃣ AnimationTree 結構

AnimationTree 內必須有一個 **AnimationNodeStateMachine**：

```
AnimationTree
└─ StateMachine
   ├─ IdleState (BlendSpace2D)
   └─ WalkState (BlendSpace2D)
```

- StateMachine 名稱 **必須叫 `StateMachine`**
- 每個 State 名稱 **必須與 State Node 名稱完全一致**
  - 例：`IdleState`, `WalkState`

---

### 2️⃣ BlendSpace2D 規則

- 每個 State 對應一個 BlendSpace2D
- BlendSpace2D 使用 `blend_position : Vector2`
- 通常放入：
  - 上 / 下 / 左 / 右 對應的動畫
- 不使用：
  - Expression
  - Auto Advance
  - Transition 條件

---

## 程式狀態機架構說明

### State（基底類）

```gdscript
class_name State extends Node
```

#### State 責任

- 定義狀態生命週期：
  - `enter()`
  - `exit()`
  - `process()`
  - `physics_process()`
- 發送狀態切換請求：
  - `transition_request(from, to)`

> State **不知道誰會接收 transition_request**  
> 只負責「提出請求」

---

### StateMachine（控制器）

```gdscript
class_name StateMachine extends Node
```

#### StateMachine 責任

- 收集所有子 State
- 注入共用資源：
  - `character`
  - `character_name`
  - `animation_tree`
  - `fsm_playback`
- 管理狀態切換：
  - 呼叫 `exit() / enter()`
- 保證：
  - 同一時間只會有一個 State 在運作

---

## blend_position 更新機制

現在 blend_position 交由 autoloads/character_manager.gd 統一管理，使用者需手動於該檔案變數 character_blend_positions 定義 blend_position 路徑。並以欲更新之 Character Node Name 作為鍵。

State 內只需要呼叫：

```gdscript
CharacterManager.update_blend_positions(...)
```

即可同步更新 **所有被定義狀態的 BlendPosition 朝向**，確保：

- Idle → Walk 不會轉向跳動
- Walk → Idle 保留最後朝向

---

## 新增一個「全新狀態」的 SOP

### Step 1️⃣ AnimationPlayer

- 新增該狀態所需的動畫（例如：`run_up`, `run_down`…）

---

### Step 2️⃣ AnimationTree

1. 在 `StateMachine` 內新增一個 State
2. 該 State 內使用 `BlendSpace2D`
3. 將動畫放入 BlendSpace2D
4. 設定好上下左右對應位置
5. 記得更新註冊 CharacterManager Blend Positions
6. **State 名稱要與之後的 State Node 名稱一致**

---

### Step 3️⃣ 新增 State 腳本

```gdscript
class_name RunState extends State
```

至少實作：

- `enter()`
- `physics_process()`
- `state_transition()`

並在 `enter()` 內：

```gdscript
fsm_playback.travel(self.name)
```

---

### Step 4️⃣ 掛到 Player

- 將 `RunState` 節點加入 `StateMachine` 底下
- 確認節點名稱正確（大小寫一致）

---

### Step 5️⃣ 加入轉移條件

在其他 State 中加入：

```gdscript
transition_request.emit(self.name, "RunState")
```

---

## 常見錯誤

### ❌ 動畫不播放

- State 名稱與 AnimationTree State 名稱不一致
- AnimationTree 未啟用（Active = true）

---

### ❌ 轉向錯亂 / 回到預設方向

- 忘記在狀態切換前更新 `blend_position`
- 新狀態沒有加入 BlendSpace2D

---

### ❌ 狀態切換無效

- State 不在 StateMachine 底下
- `transition_request` 沒有正確 connect

---

## 設計總結

> **AnimationTree 是資料  
> StateMachine 是邏輯  
> State 是行為與動畫的唯一真相**
