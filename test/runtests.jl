if VERSION >= v"0.5.0-dev+7720"
    using Base.Test
else
    using BaseTestNext
    const Test = BaseTestNext
end

import Hafta
import HaftaViz

@test HaftaViz.Hafta === Hafta
