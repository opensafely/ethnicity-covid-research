{smcl}
{* *! version 1.0.0 2019-04-23}{...}
{vieweralsosee "streg" "help streg"}{...}
{vieweralsosee "stpm2" "help stpm2"}{...}
{vieweralsosee "predictms" "help predictms"}{...}
{viewerjumpto "Syntax" "standsurv##syntax"}{...}
{viewerjumpto "Description" "standsurv##description"}{...}
{viewerjumpto "Options" "standsurv##options"}{...}
{viewerjumpto "Examples" "standsurv##examples"}{...}
{title:Title}

{p2colset 5 18 18 2}{...}
{p2col :{hi:standsurv} {hline 2}}Standardized survival and related functions{p_end}
{p2colreset}{...}


{marker syntax}{...}
{title:Syntax}

{synoptset 29 tabbed}{...}
{synopthdr}
{synoptline}
{synopt:{opt at1()}{it:...}{opt atn()}}fix specific covariate values for each cause{p_end}
{synopt:{opt atv:ars()}}the new variable names (or stub) for each at{it:n}() option{p_end}
{synopt:{opt atr:eference()}}the reference at{it:n}() option (default 1){p_end}
{synopt:{opt centile(numlist)}}centiles of the standardised survival function{p_end}
{synopt:{opt centileu:pper(#)}}upper starting value when calculating centiles{p_end}
{synopt:{opt centv:ar()}}the new variable to denote centiles{p_end}
{synopt:{opt ci}}calculates confidence intervals for each at{it:n}() option and for contrasts{p_end}
{synopt:{opt cif}}calculates cumulative incidence function for competing risks models{p_end}
{synopt:{opt contrast()}}perform contrast between covariate patterns defined by at{it:n}() options{p_end}
{synopt:{opt contrastv:ars()}}the new variable names (or stub) for each contrast{p_end}
{synopt:{opt centile(modellist)}}list of models for competing risks{p_end}
{synopt:{opt crmod:els({it:modellist})}}names of competing risk models{p_end}
{synopt:{opt f:ailure}}calculate standardised failure function (1-S(t)){p_end}
{synopt:{opt genind(stub)}}output individual predictions{p_end}
{synopt:{opt h:azard}}calculate hazard function of standardised survival curve{p_end}
{synopt:{opt indw:eights(varname)}}variable containing weights (for external standardisation){p_end}
{synopt:{opt lincom}}linear combination of at options{p_end}
{synopt:{opt lev:el(#)}}sets confidence level (default 95){p_end}
{synopt:{opt mest:imation}}use M-estimation for standard errors & confidence intervals{p_end}
{synopt:{opt no:des(#)}}number of nodes for numerical integration (default 30){p_end}
{synopt:{opt ode}}use ordinary differential equations for some integrations{p_end}
{synopt:{opt odeoptions(options)}}options for ordinary differential equations{p_end}
{synopt:{opt rmst}}calculate restricted mean survival time{p_end}
{synopt:{opt rmft}}calculate restricted mean failure time{p_end}
{synopt:{opt se}}calculates standard errors for each at{it:n}() option and for contrasts{p_end}
{synopt:{opt stub2}}override the default stubnames{it:n}() option and for contrasts{p_end}
{synopt:{opt ti:mevar(varname)}}time variable used for predictions (default _t){p_end}
{synopt:{opt toff:set(varname)}}time offset when multiple models{p_end}
{synopt:{opt tr:ansform()}}transformation to calculate standard errors when obtaining confidence intervals{p_end}
{synopt:{opt userf:unction()}}user defined function{p_end}
{synopt:{opt userfunctionv:ar()}}the new variable names (or stub) for each user defined function{p_end}
{synoptline}

{marker description}{...}
{title:Description}

{pstd}
{cmd:standsurv} is a postestimation command that calculates various standardized 
(marginal) measures after fitting a parametric survival model. These include 
standardized survival functions and a variety of measures of standardized survival
functions including hazard, centiles and restricted mean survival time. 
{p_end}

{pstd}
When standardizing, specific covariate(s) can be help constant and contrasts between
different groups can be made, for example differences and ratios.  Confidence intervals for all quantities are available. 
User-defined transformations can be calculated by providing a user-written 
Mata function.
{p_end}

{pstd}
The command also allows more than one survival model to be specified in a
competing risks setting. This allows calculation of standardized cause-specific
cumulative incidence functions and other useful measures. 
{p_end}

{pstd}
Survival model fitting commands supported include {cmd:stpm2}, {cmd:strcs}, {cmd:streg}. 
Note generalized gamma models are not current implemented for {cmd:streg} models.
{p_end}

{pstd}
Factor variables are not supported and so you must create dummy variables when 
fitting the models. 
{p_end}

{pstd}
{cmd:standsurv} creates the following variables:
{p_end}

{marker options}{...}
{title:Options}

{phang}
{opt at1(varname # [varname # ..], suboptions)}{it:..}{opt atn(varname # [varname # ..], suboptions)}
specifies covariates to fix at specific values when averaging predictions. 
For example, if {bf:x} denotes a binary covariate and you want to standardise
over all other variables in the model then using {bf:at1(x 0) at2(x 1)} will give
two standardised functions, one where {bf:x=0} and one where {bf:x=1}. 

{pmore}
Using {bf:at1(.)} will calculated the standardized quantity with all observations set to their observed values.

{pmore}
It can be sometimes be useful to set certain variables to take the values of a 
different covariate. This can be done using {bf:at1(x1 = x2)} for example. 
This can be useful when there are interactions: consider a model with 
{bf: treat age treat_age} as covariates where {bf: treat_age} is an interaction 
between treatment and age. When standardising for {bf:treat=0} and {bf:treat=1}, 
the {bf:at()} options should be {bf: at1(treat 0 treat_age 0)} and 
{bf: at2(treat 1 treat_age = age)}.

{pmore}
There are some suboptions. There are,

{phang2}
{opt atif(expression)} restricts the standardization to that selected by the 
expression. For example, if {bf: x} is an exposure covariate taking 0 for the 
unexposed and 1 for the exposed, then using {bf: at1(x 0, atif(x==1))} 
standardizes over the covariate distribution among the exposed.

{pmore}
Note {bf: atif()} allows different if expressions for each {bf: at()} option.
Often the same if expression is required for each {bf: at()} option and so
a standard single {bf: if/in} statement can be used.

{phang2}
{opt atenter(#)} specifies the start time when integrating for RMST or RMFT.

{phang2}
{opt atindweights(varname)} Multiplies each individual prediction by the specified
{it:varname}. This can be used for external (age) standardization. If the same weights
are being used for all {bf: at()} options then the main {bf: indweights()} option can
be used.

{phang2}
{opt attimevar(varname)} specified a different time variables for each at option.
Here you should be carful with contrasts. One use of different timevars is conditional survival.



{phang}
{opt atvars(stub | newvarnames)} gives the names of the new variables to be
created. This can be specified as a {it:varlist} equal to the number of at() 
options or a {it:stub} where new variables are named {it:stub}{bf:1} - 
{it:stub}{bf:n}. If this option is not specified, the names default to 
{bf:_at1} to {bf:_at}{it:n}. 

{phang}
{opt atreference(#)} the {bf:atn()} option that defines the reference category.
By default this is {bf:at1()}.

{phang}
{opt centile(numlist)} calculates centiles of the standardised survival curve
for the centiles given in {it:numlist}. The centile values are given in a
new variable, {cmd:_centvar}, or that defined using the {cmd:centvar()} option.

{phang}
{opt centileupper(#)} upper starting value when calculating centiles of the 
standardised survival curve. The default is four times the maximum survival time. 
If you have to set this, it probably means you estimate is based on extrapolated 
the survival function way beyond your observed follow-up.

{phang}
{opt centileupper(newvarname)} name of new varaible giving values of centiles.
The default is {cmd:_centvar}.

{phang}
{opt ci} calculates a {opt level(#)}% confidence interval for each standardised
function or contrast. The confidence limits are stored using the
suffix {bf:_lci} and {bf:_uci}.

{phang}
{opt cif} calculates the cause-specific cumulative incidence functions from 
competing risks models. THis must be used with {bf:crmodels()} option to list the 
cause-specific models. See XXX for naming rules...

{phang}
{opt contrast(contrastname)} calculates contrasts between standardised measures. 
Options are {bf:difference} and {bf:ratio}. There will be {it:n-1} 
new variables created, where {it:n} is the number of {bf:at()} options.

{phang}
{opt contrastvars(stub | newvarnames)} gives the new variables to create when
using the {bf:contrast()} option. This can be specified as a varlist or a {it:stub},
whereby new variables are named {it:stub}{bf:1} - {it:stub}{bf:n-1}. 
The names default to {bf:_contrast1} to {bf:_contrast}{it:n-1}.

{phang}
{opt crmodels(modellist)} gives the names of the cause-specifc models for 
competing risks. Each model nees to have been saved using estimates store.

{phang}
{opt enter(#)} gives the enter time for conditional estimates. This currently only 
works with the rmst and rmft options.

{phang}
{opt expsurv(suboptions)} indicates that expected survial should be calculated
and then compbined with the model based (relative) survival estimates to give
all cause survival. There are a number of suboptions, which are,

{phang2}
{opt agediag(varname)} gives the variable giving the age at diagnosis in years 
for subjects in the study population. Note that using integer age then
you are assuming that individuals were diagnosed on their birthday.

{phang2}
{opt datediag(varname)} gives the variable giving the date at diagnosis  
for subjects in the study population. If you do not have exact dates then you 
need to specify what you are assuming. For example, if you had dates in months 
and years you could use

{phang3}
	{bf:. gen datediag = mdy(diagmonth,1,diagyear)}
	
{phang3}
	to assume all subjects were diagnosed on the 1st of the month.

	
{phang2}
{opt expsurvvars(stub | newvarnames)} gives the names of the new variables to be
created for marginal expected survival (survival option) of marginal expected 
life expectency (RMST option). If not specified these variables will 
not be stored. The names can be specified as a {it:varlist} equal to the number 
of {bf:at()} options or a {it:stub} where new variables are named {it:stub}{bf:1} - 
{it:stub}{bf:n}. 
	
{phang2}
{opt nenter(#)} Number of split points when calculating expected survival at the time
specified in the {cmd:enter()}. The default is 30. 	
	
{phang2}
{opt pmage(varname)} gives the age variable in the population mortality file.
	
{phang2}
{opt pmmaxage(varname)} gives the maximum age in the population mortality file.
When calculating attained age to merge in the expected mortality rates any record
that is over this maximum will be set to this maximum. The default value is 99.
	
{phang2}
{opt pmmaxyear(varname)} gives the maximum year in the population mortality file.
This is potentially useful when extrapolating. When calculating attained year
to merge in the expected mortality rates any record that is over this maximum 
will be set to this maximum. 

{phang2}
{opt pmother(other)} gives the name of other variables in the population 
mortality file. For example, this is usually sex, but can also be region,
deprivation etc.

{phang2}
{opt pmrate(rate)} gives the rate variables in the population mortality file. Note 
that standsurv requires the expected mortality rate and not the expected survival.

{phang2}
{opt pmyear(varname)} gives the calendar year variable in the population 
mortality file.

{phang2}
{opt split(varname)} gives the split times when calculating expected survival (for rmst). 
Default is one year.


{phang2}
{opt using(filename)} filename of population mortality file.
	
{phang}
{opt failure} calculates the standardised failure function rather than
the standardised survival function.

{phang}
{opt genind(stubname)} outputs the predictions for each individual, i.e. the 
predicted values that feed into the average. Standsurv is concerned with marginal 
estimates, but it is sometimes of interest to look at the variation between 
individuals. Note that this only will work if {it:timevar} is a single value and
it make not work at all.

{phang}
{opt hazard} calculates the hazard function of the standardised survival
function. Note that this is not the mean of the predicted hazard functions,
but a weighted mean with weights S(t). The weights are time-dependent.

{phang}
{opt indweights(varname)} Multiplies each individual prediction by the specified
{it:varname}. This is used for external (age) standardization.

{phang}
{opt level(#)} sets the confidence level; default is level(95) or as set by {help set level}.

{phang}
{opt lincom(#...#)} calculates a linear combination of at{it:n} options. As an example, if
there were two at options then {bf:lincom(1 -1)} would calculate the difference in the
standardized estimate. This would be the same as using the {bf:contrast(difference)} option.

{phang}
{opt lincomvar(newvarname)} gives the new variable to create when
using the {bf:lincom()} option. 

{phang}
{opt mestimation} requests that standard errors are obtained using M-estimation 
(Stefanski and Boos 2002) rather than the delta-method.

{phang}
{opt nodes(#)} number of nodes when performing numerical integration to
calculate the restricted mean survival time.

{phang}
{opt ode} use ordinary differential equations (Dormand Prince 45) for numerical integration.
Currently just implemented for cumulative incidence functions and crude probabilities.

{phang}
{opt odeoptions(options)} Various options for ordinary differential equations.


{phang2}
{opt abstol(#)} absolute toleranceodeoptions - default 1e-6.

{phang2}
{opt error_control(#)} error control when reducing step size - default (5/safety)^(1/pgrow).

{phang2}
{opt initialh(#)} initial step size - default 1e-8.

{phang2}
{opt maxsteps(#)} maxiumum number of steps - default 1000.

{phang2}
{opt pgrow(#)} power using when increasing step size.

{phang2}
{opt pshrink(#)} power using when decreasing step size.

{phang2}
{opt reltol(#)} relative tolerance - default 1e-4.

{phang2}
{opt safety(#)} safety factor - default 1.

{phang2}
{opt tstart(#)} lower bound of integration.

{phang2}
{opt verbose} output details for each step.

{phang}
{opt per(#)} multiplies predictions by {it:#}. For example, when predicting 
survival {bf: per(100)} will express results as a percentage rather than a 
proportion, or when predicting hazard functions, {bf: per(1000)} gives results
per 1000 person years (if your time scale is in years of course).

{phang}
{opt rmst} calculates the restricted mean survival time. These are calculated at
the time points give in variable given in the {cmd:timevar()} option. 

{phang}
{opt rmft} calculates the restricted mean failure time. These are calculated at
the time points give in variable given in the {cmd:timevar()} option.

{phang}
{opt se} calculates the standard error  for each standardised
function or contrast. This is stored using the suffix {bf:_se}.

{phang}
{opt stub2} Overide default stub names{bf:_se}.

{phang}
{opt timevar(varname)} defines the variable used as time in the predictions. The
option is useful for large datasets where, for plotting purposes, predictions
are needed only for (say) 200 observations. Note that predictions are averaged
over the whole sample, not just those where {it:timevar} is not missing. It is
recommended that {opt timevar()} is used, as otherwise an estimate of the survival
function is obtained at each value of {bf:_t} for all subjects.
Default varname is {cmd:_t}.

{phang}
{opt toffset(varlist)} defines variables that have an offset for time for use when
predicting cause-specific cumulative incidence functions. For example, if model 1
used time since diagnosis as the time-scale and model 2 uses attained age as 
the time scale, then using {cmd:toffset(. agediag)} will make all predictions 
on the time since diagnosis time scale, but making appropriate adjustments for 
age at diagnosis.

{phang}
{opt trans(name)} transformation to apply when calculating standard errors to
obtain confidence intervals for the standardised curves. The default is
log(-log S(t)). Other possible {it:name}s are {bf:none}, {bf:log}, {bf:logit}.

{phang}
{opt userfunction(name)} give a Mata function that calculates transformations the 
standardized functions. This enables flexibility to calculate 
a wide range of potential functions. An example of a Mata function to calculate 
a difference  between two standardized function is shown below

{phang2}
{cmd:mata:}{break}
{cmd:function user_eg(at) {c -(}}{break}
{space 4}{cmd:return(at[2] - at[1])}{break}
{cmd:{c )-}}{break}
{cmd:end}{break}

{phang2}
{cmd:standsurv, at1(x1 0) at2(x1 1) timevar(tt) ci userfunction(user_eg)}

{phang}
{opt userfunctionvar(newvarname)} gives the new variable to create when
using the {bf:userfunction()} option. The name defaults to {bf:_userfunc}.

{phang}
{opt verbose} gives details about what is being estimated during the running
of the command, minaly used for developing and debugging. 

{marker examples}{...}
{title:Example 1:}

For some more detailed examples see {browse "https://pclambert.net/software/standsurv/":https://pclambert.net/software/standsurv/}

{pstd}Load example dataset:{p_end}
{phang}{stata ". webuse brcancer, clear"}

{pstd}{cmd:stset} the data:{p_end}
{phang}{stata ". stset rectime, f(censrec==1) scale(365.24)"}

{pstd}Fit {cmd:stpm2} model:{p_end}
{phang}{stata ". stpm2 hormon x5 x1 x3 x6 x7, scale(hazard) df(4) tvc(hormon x5 x3) dftvc(3)"}

{pstd}Generate variable that defines timepoints to predict at. The following creates 50 equally spaced time points between 0.05 and 5 years:{p_end}
{phang}{stata ". range timevar 0 5 50"}

{pstd}Obtain standardised curves for {bf:hormon=0} and {bf:hormon=1}.
In each case the survival curves are the average of the 686
survival curves using the observed covariate values except for {bf:hormon}.{p_end}
{phang}{stata ". standsurv, atvars(S0a S1a) at1(hormon 0) at2(hormon 1) timevar(timevar) ci"}

{pstd}Plot standardised curves:{p_end}
{phang}{stata ". line S0a S1a timevar"}

{pstd}Obtain standardised curves for {bf:hormon=0} and {bf:hormon=1}, but apply the covariate distribution amongst those with {bf:hormon=1}.{p_end}
{phang}{stata ". standsurv if hormon==1, atvars(S0b S1b) at1(hormon 0) at2(hormon 1) timevar(timevar) ci"}

{pstd}Plot standardised curves:{p_end}
{phang}{stata ". line S0b S1b timevar"}

{pstd}Obtain standardised curves for {bf:hormon=0} and {bf:hormon=1}, and calculate difference in standardised survival curves and 95 confidence interval.

{phang}{stata ". standsurv, atvars(S0c S1c) at1(hormon 0) at2(hormon 1) timevar(timevar) ci contrast(difference) contrastvar(Sdiffc)"}

{pstd}Plot difference in standardised curves and 95% confidence interval:{p_end}
{phang}{stata ". line Sdiffc* timevar"}




{title:Authors}

{pstd}Paul C. Lambert{p_end}
{pstd}Biostatistics Research Group{p_end}
{pstd}Department of Health Sciences{p_end}
{pstd}University of Leicester{p_end}
{pstd}{it: and}{p_end}
{pstd}Department of Medical Epidemiology and Biostatistics{p_end}
{pstd}Karolinska Institutet{p_end}
{pstd}E-mail: {browse "mailto:paul.lambert@le.ac.uk":paul.lambert@le.ac.uk}{p_end}

{pstd}Michael J. Crowther{p_end}
{pstd}Biostatistics Research Group{p_end}
{pstd}Department of Health Sciences{p_end}
{pstd}University of Leicester{p_end}

{phang}
Please report any errors you may find.{p_end}


{title:Acknowledgments}

{pstd}
XXXX
{p_end}


{title:References}

{phang}
Crowther MJ, Lambert PC. Parametric multi-state survival models: flexible modelling allowing transition-specific distributions with 
application to estimating clinically useful measures of effect differences. {it: Statistics in Medicine} 2017;36(29):4719-4742.

{phang}Stefanski L.A. and Boos, DD. The calculus of M-estimation. {it: The American Statistician} 2002;{bf:56};29-38.

Other references
{p_end}
