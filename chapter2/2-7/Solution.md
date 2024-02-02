# Answer to additional questions

Q: *How would your design change if each drug must be sold at a fixed price by all pharma-
cies?*
A: Price becomes an attribute of drugs instead of an attribute to 'Sells' relationship.

Q: *How would your design change if the design requirements change as follows: If a doctor
prescribes the same drug for the same patient more than once, several such prescriptions
may have to be stored.*
A: I actually designed the ER model using this specification. If it were designed according to the original specification, then I would put the date and quantity as the 'Prescribe' attributes, and Doctors, Patients, and Drugs are involved in a ternary relationship.
