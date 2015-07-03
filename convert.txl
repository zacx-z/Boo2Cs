include "boo.grm"
include "csharpAddon.grm"

function main
	replace [program]
		P [program]
	by
		P [convert_variable_declaration] [convert_function_declaration] [c_local_variable_definition] [convert_generic]
		[convert_for_in] [convert_if] [convert_elif] [convert_if_body] [convert_single_name] [convert_import_stmt]
		[convert_while] [c_generic_type_declaration] [convert_callable]
		[convert_default_function_declaration] % comment this to forbidden
		[add_semicolon_stmt] [add_semicolon_member_variable] [convert_indent] [convert_comment]
end function

rule convert_import_stmt
	replace [import_stmt_newline]
		'import N[id_with_dots] S [opt ';] E [repeat endofline]
	by
		'using N '; E
end rule

rule convert_variable_declaration
	replace [variable_declaration]
		N [id] as T [type]
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
		'( _ [expression] ')
	by
		'else 'if '( E ')
end rule

rule convert_if_body
	replace [if_body]
		': S [single_stmt]
	by
		S ';
end rule

rule convert_while
	replace [while_header]
		'while E [expression]
	deconstruct not E
		'( _ [expression] ')
	by
		while '( E')
end rule

rule convert_callable
	replace [callable_declaration]
		M [opt modifier] 'callable N [id] G [opt generic_type] '( P [variable_declaration,] ') as T [type]
	by
		M 'delegate T N G '( P ')
end rule

rule convert_single_name
	replace [id]
		'single
	by
		'float
end rule

rule c_generic_type_declaration
	replace [generic_type_declaration]
		'[ 'of N [id] '( T [type_base] ') ']
	by
		'< N '> 'where N ': T
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
		': C [opt comment] _ [newline] '{ NL [repeat endofline]
	by
		'{ C NL
end rule

rule convert_comment
	replace [comment]
		M [comment]
	construct F [comment]
		M [: 1 1]
	construct _L [number]
		0
	construct L [number]
		_L [# M]
	construct Rest [comment]
		M [: 2 L]
	construct T [comment]
		'//
	where
		F [= "#"]
	by
		T [+ Rest]
end rule

