include "boo.grm"
include "csharpAddon.grm"

function main
	replace [program]
		P [program]
	by
		P [convert_variable_declaration] [convert_function_declaration] [c_local_variable_definition] [convert_generic]
		[convert_for_in] [convert_if] [convert_elif] [convert_single_name] [convert_import_stmt]
		[convert_default_function_declaration] % comment this to forbidden
		[add_semicolon_stmt] [add_semicolon_member_variable] [convert_indent]
end function

rule convert_import_stmt
	replace [import_stmt_newline]
		'import N[id] S [opt ';] E [repeat endofline]
	by
		'using N '; E
end rule

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

rule convert_default_function_declaration
	replace [function_header]
	    'def N [id] '( P [variable_declaration,] ')
	by
		'void N '( P ')
end rule

rule convert_for_in
	replace [for_in_stmt]
	    'for V [id] 'in E [expression] I [indent] B [repeat stmt_newline] D [dedent] TAIL[repeat endofline]
	by
	   	'foreach '( 'var V 'in E ') I B D TAIL   	
end rule

rule convert_if
	replace [if_header]
		'if E [expression]
	deconstruct not E
		'( _E [expression] ')
	by
		'if '( E ')
end rule

rule convert_elif
	replace [elif_header]
		'elif E [expression]
	deconstruct not E
		'( _E [expression] ')
	by
		'else 'if '( E ')
end rule

rule convert_single_name
	replace [id]
		'single
	by
		'float
end rule

rule convert_generic
	replace [generic_type]
		'[ 'of T[id] ']
	by
		'< T '>
end rule

rule c_local_variable_definition
	replace [local_variable_definition]
		N [id] 'as T [id] '= E [expression]
	by
		T N '= E ';
end rule

rule add_semicolon_stmt
	replace [stmt_newline]
		S [single_stmt] NL [repeat endofline]
	by
		S '; NL
end rule

rule add_semicolon_member_variable
	replace [class_member_variable_declaration]
		M [modifier] D [variable_declaration] I [opt variable_initialization]
	by
		M D I ';
end rule

rule convert_indent
	replace [indent]
		': _ [newline] '{ NL [repeat endofline]
	by
		'{ NL
end rule

