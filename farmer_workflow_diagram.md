# Current Farmer Work Flow Diagram

```mermaid
graph TD
    Start([Farmer Spawns]) --> Ready[Farmer._ready()]
    Ready --> InitSpeed[Set base_speed = 10000]
    InitSpeed --> SuperReady[Call super() - WorkingCharacter._ready()]
    
    SuperReady --> WCInit[WorkingCharacter._ready()]
    WCInit --> IdlerReady[Idler._ready()]
    IdlerReady --> LivingReady[LivingEntity._ready()]
    LivingReady --> MoverReady[Mover._ready()]
    
    %% Main Process Loop
    MoverReady --> ProcessTick[TimeManager calls _process_tick()]
    
    ProcessTick --> LivingTick[LivingEntity._process_tick()]
    LivingTick --> UpdateHunger[Update hunger & health]
    UpdateHunger --> HealthCheck{Health <= 0?}
    
    HealthCheck -->|Yes| Die[Die & queue_free()]
    HealthCheck -->|No| HungerCheck{Hunger < threshold?}
    
    HungerCheck -->|Yes| HandleHunger[WorkingCharacter._handle_hunger()]
    HandleHunger --> FindFood[Find food source]
    FindFood --> SetEatAction[Set Action.EATING]
    SetEatAction --> MoveToFood[Move to food position]
    MoveToFood --> EatFood[Eat from source]
    EatFood --> ReturnToWork{Has active_work?}
    
    ReturnToWork -->|Yes| SetWorkAction[Set Action.WORK]
    ReturnToWork -->|No| SetIdleAction[Set Action.IDLE]
    
    HungerCheck -->|No| WorkingTick[WorkingCharacter._process_tick()]
    
    WorkingTick --> StaminaCheck{Stamina <= 0?}
    StaminaCheck -->|Yes| SwitchToRest[Switch to REST]
    StaminaCheck -->|No| FreeCheck{free == true?}
    
    FreeCheck -->|No| IdlerTick[Idler._process_tick()]
    FreeCheck -->|Yes| ActionMatch{Match action}
    
    ActionMatch -->|REST| ProcessRest[Process REST]
    ActionMatch -->|WORK| ProcessWork[Process WORK]
    ActionMatch -->|IDLE| ProcessIdle[Process IDLE]
    
    %% REST Flow
    ProcessRest --> RestArrived{Arrived at cleric?}
    RestArrived -->|No| MoveToCleric[Move toward cleric]
    RestArrived -->|Yes| RestoreStamina[Restore stamina +10]
    RestoreStamina --> StaminaFull{Stamina >= max?}
    StaminaFull -->|Yes| SetWorkFromRest[Set Action.WORK]
    StaminaFull -->|No| ContinueRest[Continue resting]
    
    %% WORK Flow
    ProcessWork --> HasWork{active_work == null?}
    HasWork -->|Yes| FindWork[Farmer._find_work()]
    HasWork -->|No| WorkArrived{Arrived at work?}
    
    %% Farmer Work Finding Logic
    FindWork --> HasAgua{carried_agua > 0?}
    HasAgua -->|Yes| ClaimAguaWork[Claim "agua" work]
    HasAgua -->|No| ClaimCollectWork[Claim "collect_agua" work]
    
    ClaimAguaWork --> AguaFound{Found agua work?}
    ClaimCollectWork --> CollectFound{Found collect work?}
    
    AguaFound -->|No| ClaimAnyWork[Claim any farmer work]
    CollectFound -->|No| ClaimAnyWork
    
    ClaimAnyWork --> AnyWorkFound{Found any work?}
    AnyWorkFound -->|Yes| CheckAguaWork{Work type == "agua"?}
    AnyWorkFound -->|No| NoWorkFound[No work available]
    
    CheckAguaWork -->|Yes| ReleaseAguaWork[Release agua work]
    ReleaseAguaWork --> ClaimCollectWork
    CheckAguaWork -->|No| SetWorkAction
    
    NoWorkFound --> StaminaCheck2{Stamina == max?}
    StaminaCheck2 -->|Yes| SwitchToIdle[Switch to IDLE]
    StaminaCheck2 -->|No| SwitchToRest
    
    WorkArrived -->|No| MoveToWork[Move toward work]
    WorkArrived -->|Yes| DoWork[Farmer._do_work()]
    
    %% Farmer Work Execution
    DoWork --> WorkType{Work type?}
    WorkType -->|collect_agua| CollectAgua[Collect agua +1]
    WorkType -->|agua| CheckAgua{carried_agua > 0?}
    WorkType -->|other| DoNormalWork[Do normal work]
    
    CheckAgua -->|Yes| WaterPlant[Water plant -1 agua]
    CheckAgua -->|No| AbandonWork[Abandon work]
    
    CollectAgua --> ClearWork[Clear active_work]
    WaterPlant --> ClearWork
    DoNormalWork --> ClearWork
    AbandonWork --> ClearWork
    
    ClearWork --> ReduceStamina[Reduce stamina -effort]
    ReduceStamina --> UpdateSpeed[Update speed]
    UpdateSpeed --> ContinueWork[Continue working]
    
    %% IDLE Flow
    ProcessIdle --> IdleHasWork{active_work == null?}
    IdleHasWork -->|Yes| IdleFindWork[Find work]
    IdleHasWork -->|No| IdleStaminaCheck{Stamina > 0?}
    
    IdleFindWork --> IdleWorkFound{Found work?}
    IdleWorkFound -->|Yes| SetWorkFromIdle[Set Action.WORK]
    IdleWorkFound -->|No| IdlerTick
    
    IdleStaminaCheck -->|Yes| IdleWorkCheck{Has work?}
    IdleStaminaCheck -->|No| IdlerTick
    IdleWorkCheck -->|Yes| SetWorkFromIdle
    IdleWorkCheck -->|No| IdlerTick
    
    %% IDLER Flow (Conflicting!)
    IdlerTick --> IdlerArrived{Arrived at idle target?}
    IdlerArrived -->|No| IdlerMove[Move toward idle target]
    IdlerArrived -->|Yes| IdlerPause{Pause ticks > 0?}
    
    IdlerPause -->|Yes| DecrementPause[Decrement pause ticks]
    IdlerPause -->|No| PickNewTarget[Pick new idle target]
    
    PickNewTarget --> SetIdleTarget[Set new target_position]
    SetIdleTarget --> IdlerMove
    DecrementPause --> IdlerMove
    
    %% Movement
    MoveToFood --> ProcessTick
    MoveToCleric --> ProcessTick
    MoveToWork --> ProcessTick
    IdlerMove --> ProcessTick
    ContinueWork --> ProcessTick
    ContinueRest --> ProcessTick
    SetWorkAction --> ProcessTick
    SetIdleAction --> ProcessTick
    SetWorkFromRest --> ProcessTick
    SetWorkFromIdle --> ProcessTick
    SwitchToIdle --> ProcessTick
    SwitchToRest --> ProcessTick
    
    %% Styling
    classDef farmerSpecific fill:#e1f5fe
    classDef workingChar fill:#f3e5f5
    classDef idler fill:#fff3e0
    classDef living fill:#e8f5e8
    classDef problem fill:#ffebee
    
    class FindWork,HasAgua,ClaimAguaWork,ClaimCollectWork,AguaFound,CollectFound,ClaimAnyWork,AnyWorkFound,CheckAguaWork,ReleaseAguaWork,DoWork,WorkType,CollectAgua,CheckAgua,WaterPlant,AbandonWork farmerSpecific
    class ProcessWork,ProcessRest,ProcessIdle,HasWork,WorkArrived,DoNormalWork,ClearWork,ReduceStamina,UpdateSpeed,ContinueWork workingChar
    class IdlerTick,IdlerArrived,IdlerMove,IdlerPause,DecrementPause,PickNewTarget,SetIdleTarget idler
    class LivingTick,UpdateHunger,HealthCheck,HungerCheck,HandleHunger living
    class IdlerTick,SetIdleTarget problem
```

## Key Issues Highlighted

### 🔴 **Critical Problem: Conflicting State Management**
- **Idler** runs `_process_tick()` and sets `target_position` independently
- **WorkingCharacter** also sets `target_position` for work
- **Result**: Idler overwrites work targets, causing farmers to wander instead of work

### 🟡 **Farmer-Specific Logic**
- Farmer has custom `_find_work()` logic for agua management
- Farmer has custom `_do_work()` logic for agua collection/consumption
- This logic is tied to the farmer class instead of the work type

### 🟢 **Working Flow**
- Health/hunger checks happen first (highest priority)
- Stamina checks determine rest needs
- Work finding and execution follows after survival needs

### 🔵 **State Transitions**
- Multiple `_process_tick()` methods run in inheritance chain
- No clear priority system between different behaviors
- States can conflict and override each other unpredictably
