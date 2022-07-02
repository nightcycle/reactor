local Game = {}
Game.__index = Game

-- ported OOP API
function Game:BindToClose(...) return game:BindToClose(...) end
function Game:IsLoaded(...) return game:IsLoaded(...) end
function Game:FindService(...) return game:FindService(...) end
function Game:ClearAllChildren(...) return game:ClearAllChildren(...) end
function Game:Clone(...) return game:Clone(...) end
function Game:Destroy(...) return game:Destroy(...) end
function Game:FindFirstAncestor(...) return game:FindFirstAncestor(...) end
function Game:FindFirstAncestorOfClass(...) return game:FindFirstAncestorOfClass(...) end
function Game:FindFirstChild(...) return game:FindFirstChild(...) end
function Game:FindFirstChildOfClass(...) return game:FindFirstChildOfClass(...) end
function Game:FindFirstChildWhichIsA(...) return game:FindFirstChildWhichIsA(...) end
function Game:FindFirstDescendant(...) return game:FindFirstDescendant(...) end
function Game:GetActor(...) return game:GetActor(...) end
function Game:GetAttribute(...) return game:GetAttribute(...) end
function Game:GetAttributeChangedSignal(...) return game:GetAttributeChangedSignal(...) end
function Game:GetAttributes(...) return game:GetAttributes(...) end
function Game:GetChildren(...) return game:GetChildren(...) end
function Game:GetDescendants(...) return game:GetDescendants(...) end
function Game:GetFullName(...) return game:GetFullName(...) end
function Game:GetPropertyChangedSignal(...) return game:GetPropertyChangedSignal(...) end
function Game:IsA(...) return game:IsA(...) end
function Game:IsAncestorOf(...) return game:IsAncestorOf(...) end
function Game:IsDescendantOf(...) return game:IsDescendantOf(...) end
function Game:SetAttribute(...) return game:SetAttribute(...) end

return Game