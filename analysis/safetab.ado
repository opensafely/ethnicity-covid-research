cap prog drop safetab
prog define safetab, byable(recall)

marksample touse
local if " if `touse'"
local commapos = strpos("`0'", ",")
local commaposm1 = `commapos'-1

if `commapos'>0 {
	local main = substr("`0'", 1, `commaposm1')
	local options = substr("`0'", `commapos', .)
	}
else local main `0'

local ifpos = strpos("`main'", " if ")
local ifposm1 = `ifpos'-1

local inpos = strpos("`main'", " in ")
local inposm1 = `inpos'-1

if `inpos'>0 & `ifpos'>0 {
	noi di in red "if cannot be combined with in"
	error 999
	}

if `ifpos'>0{
local if = substr("`main'", `ifpos', .)
local if "`if' & `touse'"
local main = substr("`main'", 1, `ifposm1')
}

if `inpos'>0{
local in = substr("`main'", `inpos',.)
local main = substr("`main'", 1, `inposm1')
}

qui tab `main' `if' `in', matcell(T)
m: T=st_matrix("T")
m: T=(T:+(10:*(T:==0)))
m: st_numscalar("checkmin", min(T) )


if checkmin>5 tab `main' `if' `in' `options'
else noi di _n "**TABLE OF `main' REDACTED DUE TO SMALL N**" _n

end

