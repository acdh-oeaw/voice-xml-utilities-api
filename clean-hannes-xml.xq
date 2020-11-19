for $n in (//*:NOTstart,//*:NOTend,//*:seg[not(ancestor::*:u)],//@debug,//@idcollect,//@txt)
(: return $n, :)
return delete node $n,
for $vocal in //*:vocal[@type='wordlike']
let $computed_id := xs:string($vocal/../@xml:id)||'_v'||count($vocal/preceding-sibling::*:vocal)+count($vocal/../preceding-sibling::*:vocal)
(: return $computed_id :)
return insert node attribute {'xml:id'}{$computed_id} as first into $vocal