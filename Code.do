* NIE
preserve 
keep if anygrade==1	

expand 3
sort id
by id: gen copy=_n

capture program drop any_sem_nie
program define any_sem_nie, rclass


replace avgqualitycomposite=. if copy==2
replace anysegregated=0 if copy==2
replace d_senas_sem_z_w1=. if copy==2

replace avgqualitycomposite=. if copy==3
replace anysegregated=1 if copy==3
replace d_senas_sem_z_w1=. if copy==3

gen mx=avgqualitycomposite*anysegregated if copy==1

preserve
* Using 'real' observations 
reg avgqualitycomposite anysegregated w1_interview_age i.w1_southbirth i.w1_parental_education_HS_m i.w1_female if copy==1 
restore 

predict cf_m_x0 if copy==2 
predict cf_m_x1 if copy==3 

replace avgqualitycomposite=cf_m_x0 if copy==2 
replace avgqualitycomposite=cf_m_x1 if copy==3 

replace anysegregated=1 if copy==2  // setting exposure to 1 in both counterfactuals
replace mx=avgqualitycomposite*anysegregated 

preserve
reg d_senas_sem_z_w1 anysegregated avgqualitycomposite mx w1_interview_age i.w1_southbirth i.w1_parental_education_HS_m i.w1_female if copy==1
restore 

predict cf_y_x1_cf_m_x0 if copy==2 
predict cf_y_x1_cf_m_x1 if copy==3 

sum cf_y_x1_cf_m_x0 if copy==2 
scalar mean_cf_y_x1_cf_m_x0=r(mean)
sum cf_y_x1_cf_m_x1 if copy==3 
scalar mean_cf_y_x1_cf_m_x1=r(mean)

return scalar beta_nie= scalar(mean_cf_y_x1_cf_m_x1) - scalar(mean_cf_y_x1_cf_m_x0) 

drop mx cf_m_x0 cf_m_x1 cf_y_x1_cf_m_x0 cf_y_x1_cf_m_x1

end 
bootstrap nie=r(beta_nie), r(2000) seed(1234) cluster(id) idcluster(newid): any_sem_nie 
estat bootstrap, all 

restore

* NDE
preserve 
keep if anygrade==1	

expand 3
sort id
by id: gen copy=_n

capture program drop any_sem_nde
program define any_sem_nde, rclass


replace avgqualitycomposite=. if copy==2
replace anysegregated=0 if copy==2
replace d_senas_sem_z_w1=. if copy==2

replace avgqualitycomposite=. if copy==3
replace anysegregated=0 if copy==3
replace d_senas_sem_z_w1=. if copy==3

gen mx=avgqualitycomposite*anysegregated if copy==1

preserve
* Using real observations regress exposure on mediator 
reg avgqualitycomposite anysegregated w1_interview_age i.w1_southbirth i.w1_parental_education_HS_m i.w1_female if copy==1 
restore 

predict cf_m_x0 if copy==2 | copy==3

replace avgqualitycomposite=cf_m_x0 if copy==2 
replace avgqualitycomposite=cf_m_x0 if copy==3 

replace anysegregated=1 if copy==2  
replace anysegregated=0 if copy==3 

replace mx=avgqualitycomposite*anysegregated 

preserve
* Using real observations regress exposure on outcome, accounting for mediator and M-E intx
reg d_senas_sem_z_w1 anysegregated avgqualitycomposite mx w1_interview_age i.w1_southbirth i.w1_parental_education_HS_m i.w1_female if copy==1
restore 

predict cf_y_x1_cf_m_x0 if copy==2 
predict cf_y_x0_cf_m_x0 if copy==3 

sum cf_y_x1_cf_m_x0 if copy==2 
scalar mean_cf_y_x1_cf_m_x0=r(mean)
sum cf_y_x0_cf_m_x0 if copy==3 
scalar mean_cf_y_x0_cf_m_x0=r(mean)

return scalar beta_nde= scalar(mean_cf_y_x1_cf_m_x0) - scalar(mean_cf_y_x0_cf_m_x0) 

drop mx cf_m_x0 cf_y_x1_cf_m_x0 cf_y_x0_cf_m_x0
end 
bootstrap nde=r(beta_nde), r(2000) seed(1234) cluster(id) idcluster(newid): any_sem_nde 
estat bootstrap, all 

restore
