package panos

default allow = false

duplicate[msg] {
	dup := input
    some i, j
    dup[i].name == dup[j].name
    i != j
    msg := sprintf("Two duplicate tags w/the same name '%v'",[dup[i].name])
}

duplicate[msg]{
	dup := input[_]
    some i, j
    dup.rule[i].name == dup.rule[j].name
    i != j
    msg := sprintf("Two duplicate rules w/the same name '%v'",[dup.rule[i].name])
}

duplicate[msg]{
	dup := input[_]
    some i, j
    dup.exception[i].name == dup.exception[j].name
    i != j
    msg := sprintf("Two duplicate exceptions w/the same name '%v'",[dup.exception[i].name])
}

duplicate[msg]{
	dup := input[_]
    some i, j
    dup.decoder[i].name == dup.decoder[j].name
    i != j
    msg := sprintf("Two duplicate decoders w/the same name '%v'",[dup.decoder[i].name])
}

duplicate[msg]{
	dup := input[_]
    some i, j
    dup.application_exception[i].name == dup.application_exception[j].name
    i != j
    msg := sprintf("Two duplicate application exceptions w/the same name '%v'",[dup.application_exception[i].name])
}

duplicate[msg]{
	dup := input[_]
    some i, j
    dup.machine_learning_model[i].model == dup.machine_learning_model[j].model
    i != j
    msg := sprintf("Two duplicate machine learning models w/the same name '%v'",[dup.machine_learning_model[i].model])
}

duplicate[msg]{
	dup := input[_]
    some i, j
    dup.machine_learning_exception[i].name == dup.machine_learning_exception[j].name
    i != j
    msg := sprintf("Two duplicate machine learning exceptions w/the same name '%v'",[dup.machine_learning_exception[i].name])
}

duplicate[msg]{
	dup := input[_]
    some i, j
    dup.target[i].serial == dup.target[j].serial
    i != j
    msg := sprintf("Two duplicate targets w/the same serial number '%v'",[dup.target[i].serial])
}



# allows only if there are no duplicates
allow {
	count(duplicate) == 0
}