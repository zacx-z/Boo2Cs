include "boo.grm"
include "csharpAddon.grm"

function main
	replace [program]
		P [program]
	by
		P [convert_variable_declaration] [convert_function_declaration] [c_local_variable_definition] [convert_generic] [add_semicolon] [convert_indent]
end function

rule convert_variable_declaration
	replace [variable_declaration]
		N [id] as T[id]
	by
		T N
end rule

rule convert_function_declaration
	replace [function_header]
	    'def N [id] '( P [variable_declaration,] ') T [opt function_type]
	deconstruct T
		'as _T [id]
	by
		_T N '( P ')
end rule

rule convert_generic
	replace [generic_type]
		'[ 'of T[id] ']
	by
		'< T'>
end rule

rule c_local_variable_definition
	replace [local_variable_definition]
		N [id] 'as T [id] '= E [expression]
	by
		T N '= E ';
end rule

rule add_semicolon
	replace [single_stmt_newline]
		S [single_stmt] NL [repeat endofline]
	by
		S '; NL
end rule

rule convert_indent
	replace [indent]
		': _ [newline] '{ NL [repeat endofline]
	by
		'{ NL
end rule
