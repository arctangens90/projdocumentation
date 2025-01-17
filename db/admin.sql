PGDMP         .                y            turkey    11.2    13.1 �    �           0    0    ENCODING    ENCODING        SET client_encoding = 'UTF8';
                      false            �           0    0 
   STDSTRINGS 
   STDSTRINGS     (   SET standard_conforming_strings = 'on';
                      false            �           0    0 
   SEARCHPATH 
   SEARCHPATH     8   SELECT pg_catalog.set_config('search_path', '', false);
                      false            �           1262    232030    turkey    DATABASE     c   CREATE DATABASE turkey WITH TEMPLATE = template0 ENCODING = 'UTF8' LOCALE = 'Russian_Russia.1251';
    DROP DATABASE turkey;
                postgres    false            	            2615    232695    admin    SCHEMA        CREATE SCHEMA admin;
    DROP SCHEMA admin;
                postgres    false            ^           1255    232928 #   add_department(integer, text, json)    FUNCTION     B  CREATE FUNCTION admin.add_department(idep_dep_index integer, idep_name text, idep_properties json, OUT dep_index integer, OUT err_msg text) RETURNS record
    LANGUAGE plpgsql
    AS $$
begin
	dep_index = -1;
	if nullif(idep_name, '') is null then err_msg = 'Empty department name'; return; end if;
	insert into admin.departments as d (dep_dep_index, dep_name, dep_properties) 
	values(idep_dep_index, idep_name, idep_properties)
	returning d.dep_index into dep_index;
	return;
exception	
	when foreign_key_violation then err_msg = 'Invalid parent department'; return;
end;
$$;
 �   DROP FUNCTION admin.add_department(idep_dep_index integer, idep_name text, idep_properties json, OUT dep_index integer, OUT err_msg text);
       admin          postgres    false    9            a           1255    232935    add_funcblock(text, text)    FUNCTION     �  CREATE FUNCTION admin.add_funcblock(ifb_name text, ifb_fullname text, OUT fb_index integer, OUT err_msg text) RETURNS record
    LANGUAGE plpgsql
    AS $$
begin
	fb_index = -1;
	if nullif(ifb_name, '') is null then err_msg = 'Empty block name'; return; end if;	
	
	insert into admin.funcblocks as r (fb_name, fb_fullname)
	values(ifb_name, ifb_fullname)
	returning r.fb_index into fb_index;
	return;
	
	exception
		when unique_violation then err_msg = 'Block full name is already exists'; return; 

end;
$$;
 m   DROP FUNCTION admin.add_funcblock(ifb_name text, ifb_fullname text, OUT fb_index integer, OUT err_msg text);
       admin          postgres    false    9            e           1255    232941 '   add_funcblockresource(integer, integer)    FUNCTION     �  CREATE FUNCTION admin.add_funcblockresource(ifb_index integer, ires_index integer, OUT err_msg text) RETURNS text
    LANGUAGE plpgsql
    AS $$
declare 
err_key text;
begin
    insert into admin.funcblockresources(fb_index, res_index)
	values(ifb_index, ires_index);
	return;
							
exception
	when foreign_key_violation then 
		begin 
		  GET STACKED DIAGNOSTICS err_key =CONSTRAINT_NAME; 
		  Raise info '%', err_key;
			if upper(err_key) = 'FBRES_F_FKEY' then 
				err_msg = 'Invalid block'; 
			else
				err_msg = 'Invalid resource';
			end if;
			return;
		end;
	when unique_violation then err_msg = 'Resource is already assigned to block'	;						

end;
$$;
 d   DROP FUNCTION admin.add_funcblockresource(ifb_index integer, ires_index integer, OUT err_msg text);
       admin          postgres    false    9            c           1255    232940 #   add_funcblockrole(integer, integer)    FUNCTION     �  CREATE FUNCTION admin.add_funcblockrole(ifb_index integer, irole_index integer, OUT err_msg text) RETURNS text
    LANGUAGE plpgsql
    AS $$
declare 
err_key text;
begin
    insert into admin.funcblockroles(fb_index, role_index)
	values(ifb_index, irole_index);
	return;
							
exception
	when foreign_key_violation then 
		begin 
		  GET STACKED DIAGNOSTICS err_key =CONSTRAINT_NAME; 
		  Raise info '%', err_key;
			if upper(err_key) = 'FBROLE_F_FKEY' then 
				err_msg = 'Invalid block'; 
			else
				err_msg = 'Invalid role';
			end if;
			return;
		end;
	when unique_violation then err_msg = 'Block is already assigned to role'	;						

end;
$$;
 a   DROP FUNCTION admin.add_funcblockrole(ifb_index integer, irole_index integer, OUT err_msg text);
       admin          postgres    false    9            _           1255    232929 *   add_resource(integer, text, text, integer)    FUNCTION     o  CREATE FUNCTION admin.add_resource(ires_res_index integer, ires_name text, ires_fullname text, irtp_index integer, OUT res_index integer, OUT err_msg text) RETURNS record
    LANGUAGE plpgsql
    AS $$
declare 
err_key text;
begin
	res_index = -1;
	if nullif(ires_name, '') is null then err_msg = 'Empty resource name'; return; end if;
	--Checking resource type
	if irtp_index is not null and not exists 
		(select * from admin.resourcetypes where is_visible and rtp_index =irtp_index  ) then
			err_msg = 'Invalid resource type';
			return;
	end if;	
	
	insert into admin.resources as r(res_res_index, res_name, res_fullname, rtp_index) 
	values(ires_res_index, ires_name, ires_fullname, irtp_index)
	returning r.res_index into res_index;
	return;
exception	
	when foreign_key_violation then 
		begin 
		  GET STACKED DIAGNOSTICS err_key =CONSTRAINT_NAME; 
		  Raise info '%', err_key;
			if upper(err_key) = 'RES_RR_FKEY' then 
				err_msg = 'Invalid parent resource'; 
			else
				err_msg = 'Invalid resource type';
			end if;
			return;
		end;
	when unique_violation then err_msg ='Full name is already exists'	; return;	
end;
$$;
 �   DROP FUNCTION admin.add_resource(ires_res_index integer, ires_name text, ires_fullname text, irtp_index integer, OUT res_index integer, OUT err_msg text);
       admin          postgres    false    9            b           1255    232931    add_resourcetype(text, text)    FUNCTION       CREATE FUNCTION admin.add_resourcetype(irtp_name text, irtp_fullname text, OUT rtp_index integer, OUT err_msg text) RETURNS record
    LANGUAGE plpgsql
    AS $$
begin
	rtp_index = -1;
	if nullif(irtp_name, '') is null then err_msg = 'Empty type name'; return; end if;	
	--check reserved names by system:
	if exists (select 1 from admin.resourcetypes
			   where trim(upper(rtp_name))=trim(upper(irtp_name)) and not is_visible) then
	err_msg = 'Type name is reserved by system';
	return;
	end if;
	
	insert into admin.resourcetypes as r (rtp_name, rtp_fullname, is_visible)
	values(irtp_name, irtp_fullname, true)
	returning r.rtp_index into rtp_index;
	return;
	
	exception
		when unique_violation then err_msg = 'Type full name is already exists'; return; 

end;
$$;
 s   DROP FUNCTION admin.add_resourcetype(irtp_name text, irtp_fullname text, OUT rtp_index integer, OUT err_msg text);
       admin          postgres    false    9            `           1255    232930    add_role(text, text)    FUNCTION       CREATE FUNCTION admin.add_role(irole_name text, irole_fullname text, OUT role_index integer, OUT err_msg text) RETURNS record
    LANGUAGE plpgsql
    AS $$
begin
	role_index = -1;
	if nullif(irole_name, '') is null then err_msg = 'Empty role name'; return; end if;	
	
	insert into admin.roles as r (role_name, role_fullname)
	values(irole_name, irole_fullname)
	returning r.role_index into role_index;
	return;
	
	exception
		when unique_violation then err_msg = 'Role full name is already exists'; return; 

end;
$$;
 n   DROP FUNCTION admin.add_role(irole_name text, irole_fullname text, OUT role_index integer, OUT err_msg text);
       admin          postgres    false    9            [           1255    232909 #   add_user(text, text, integer, json)    FUNCTION     �  CREATE FUNCTION admin.add_user(ilogin text, ipassword text, idep_index integer, iproperties json, OUT user_index integer, OUT err_msg text) RETURNS record
    LANGUAGE plpgsql
    AS $$
begin
	user_index = -1;
	if nullif(ilogin, '') is null then err_msg = 'Empty login'; return; end if;
	if nullif(ipassword, '') is null then err_msg = 'Empty password'; return; end if;	
	
	insert into admin.users as u (dep_index, user_login, user_password, user_properties)
	values(idep_index, ilogin, crypt(ipassword, gen_salt('md5')), iproperties)
	returning u.user_index into user_index;
	return;
	
	exception
		when unique_violation then err_msg = 'Login is already existed'; return; 

end;
$$;
 �   DROP FUNCTION admin.add_user(ilogin text, ipassword text, idep_index integer, iproperties json, OUT user_index integer, OUT err_msg text);
       admin          postgres    false    9            d           1255    232938    add_userrole(integer, integer)    FUNCTION     �  CREATE FUNCTION admin.add_userrole(iuser_index integer, irole_index integer, OUT err_msg text) RETURNS text
    LANGUAGE plpgsql
    AS $$
declare 
err_key text;
begin
    insert into admin.userroles(user_index, role_index)
	values(iuser_index, irole_index);
	return;
							
exception
	when foreign_key_violation then 
		begin 
		  GET STACKED DIAGNOSTICS err_key =CONSTRAINT_NAME; 
		  Raise info '%', err_key;
			if upper(err_key) = 'USERROLE_U_FKEY' then 
				err_msg = 'Invalid user'; 
			else
				err_msg = 'Invalid role';
			end if;
			return;
		end;
	when unique_violation then err_msg = 'Role is already assigned to user'	;						

end;
$$;
 ^   DROP FUNCTION admin.add_userrole(iuser_index integer, irole_index integer, OUT err_msg text);
       admin          postgres    false    9            v           1255    232999    add_userrole_json(json)    FUNCTION     b  CREATE FUNCTION admin.add_userrole_json(ijson json) RETURNS void
    LANGUAGE plpgsql
    AS $$
declare 
insrows integer;
delrows integer;
datarows integer;
begin
select count (*) into datarows from json_array_elements_text(ijson->'role_list');
if datarows!=0 then													
	with NewData as ( select (ijson->>'user_index')::integer user_index, r::integer role_index
				  from json_array_elements_text(ijson->'role_list') r),
	ins as (insert into admin.userroles as u (user_index, role_index)
		   select user_index, role_index from NewData
		   on conflict (user_index, role_index) do nothing
		   returning u.role_index as insrows),
	del as (delete from admin.userroles u  using NewData n 
			where u.user_index = n.user_index and u.role_index 
			not in (select role_index from NewData)
		   returning u.role_index as delrows) ,
	insr as (select count(*) cins  from ins),
	delr as (select count(*) cdel  from del)
	select cins, cdel into insrows, delrows from insr, delr;	
	raise info'%, %', insrows, delrows;	
else
	delete from admin.userroles where user_index = (ijson->>'user_index')::integer;
end if;

end;
$$;
 3   DROP FUNCTION admin.add_userrole_json(ijson json);
       admin          postgres    false    9            i           1255    232951 ,   change_password_by_user(integer, text, text)    FUNCTION     �  CREATE FUNCTION admin.change_password_by_user(iuser_index integer, old_password text, new_password text, OUT err_msg text) RETURNS text
    LANGUAGE plpgsql
    AS $$
begin
	if  not(coalesce(admin.check_password(iuser_index, old_password), false)) then
		err_msg = 'Uncorrect password';
		return;
	else
		update admin.users set user_password = crypt(new_password, gen_salt('md5')) where user_index = iuser_index;
		return;
	end if;
end;
$$;
 z   DROP FUNCTION admin.change_password_by_user(iuser_index integer, old_password text, new_password text, OUT err_msg text);
       admin          postgres    false    9            x           1255    233625 "   change_password_by_user_json(json)    FUNCTION     �   CREATE FUNCTION admin.change_password_by_user_json(ijson json) RETURNS text
    LANGUAGE plpgsql
    AS $$
begin
	return admin.change_password_by_user((ijson->>'user_index')::integer, 
										 ijson->>'old_password', ijson->>'new_password');
end;
$$;
 >   DROP FUNCTION admin.change_password_by_user_json(ijson json);
       admin          postgres    false    9            y           1255    233626 "   change_user_properties(json, text)    FUNCTION     n  CREATE FUNCTION admin.change_user_properties(properties json, external_user text) RETURNS void
    LANGUAGE plpgsql
    AS $$
declare 
idep_index integer;
iproperties json;
begin
	idep_index = (properties->>'dep_index')::integer;
	--if idep_index not in (select dep_index from admin.users where user_index = iuser_index ) then
	update admin.users set dep_index = idep_index where user_index = (properties->>'user_index')::integer;
	--Здесь код на логгирование изменений
	--end if;
	iproperties = properties->'user_properties';
	--if iproperties::text not in (select user_properties::text from admin.users where user_index = iuser_index) then
	--Здесь код на логгирование изменений

	update admin.users set user_properties = iproperties where user_index = (properties->>'user_index')::integer;
	--end if;
		
end;
$$;
 Q   DROP FUNCTION admin.change_user_properties(properties json, external_user text);
       admin          postgres    false    9            {           1255    233629 +   change_user_properties(integer, json, text)    FUNCTION        CREATE FUNCTION admin.change_user_properties(iuser_index integer, properties json, external_user text, OUT err_msg text) RETURNS text
    LANGUAGE plpgsql
    AS $$
declare 
idep_index integer;
iproperties json;
num integer;
begin
	idep_index = (properties->>'dep_index')::integer;
	--if idep_index not in (select dep_index from admin.users where user_index = iuser_index ) then
	--update admin.users set dep_index = idep_index where user_index = iuser_index;
	--Здесь код на логгирование изменений
	--end if;
	iproperties = properties->'user_properties';
	--if iproperties::text not in (select user_properties::text from admin.users where user_index = iuser_index) then
	--Здесь код на логгирование изменений
	with x as (
	update admin.users set dep_index = idep_index, user_properties = iproperties where user_index = iuser_index
	returning *) select count(*) into num from x;
	if num=0 then
		err_msg='User not found';
	end if;
	--end if;
	return ;	
end;
$$;
 x   DROP FUNCTION admin.change_user_properties(iuser_index integer, properties json, external_user text, OUT err_msg text);
       admin          postgres    false    9            Z           1255    232912    check_password(integer, text)    FUNCTION     5  CREATE FUNCTION admin.check_password(iuser_index integer, ipassword text) RETURNS boolean
    LANGUAGE plpgsql
    AS $$
--password check
declare res boolean;
begin
	select u.user_password = crypt(ipassword, u.user_password) into res
	from admin.users u
	where user_index = iuser_index;
	return res;
end;
$$;
 I   DROP FUNCTION admin.check_password(iuser_index integer, ipassword text);
       admin          postgres    false    9            ]           1255    232913    check_password(text, text)    FUNCTION     7  CREATE FUNCTION admin.check_password(ilogin text, ipassword text) RETURNS boolean
    LANGUAGE plpgsql
    AS $$
--проверка пароля
declare res boolean;
begin
	select u.user_password = crypt(ipassword, u.user_password) into res
	from admin.users u
	where user_login = ilogin;
	return res;
end;
$$;
 A   DROP FUNCTION admin.check_password(ilogin text, ipassword text);
       admin          postgres    false    9            '           1255    233425    close_session(integer)    FUNCTION     �   CREATE FUNCTION admin.close_session(iuss_index integer) RETURNS void
    LANGUAGE plpgsql
    AS $$
begin
	update admin.usersessions set date_end = localtimestamp where uss_index = iuss_index;
end;
$$;
 7   DROP FUNCTION admin.close_session(iuss_index integer);
       admin          postgres    false    9            h           1255    232947 &   create_session(integer, integer, inet)    FUNCTION     �  CREATE FUNCTION admin.create_session(iuser_index integer, irole_index integer, iurl inet, OUT uss_index integer, OUT err_msg text) RETURNS record
    LANGUAGE plpgsql
    AS $$
declare 
err_key text;
begin
	uss_index = -1;
    insert into admin.usersessions as s(user_index, role_index, date_beg, uss_url)
	values(iuser_index, irole_index, localtimestamp, iurl)
	returning s.uss_index into uss_index;
	return;
							
exception
	when foreign_key_violation then 
		begin 
		  GET STACKED DIAGNOSTICS err_key =CONSTRAINT_NAME; 
		  Raise info '%', err_key;
			if upper(err_key) = 'USS_U_FKEY' then 
				err_msg = 'Invalid user'; 
			else
				err_msg = 'Invalid role';
			end if;
			return;
		end;					

end;
$$;
 �   DROP FUNCTION admin.create_session(iuser_index integer, irole_index integer, iurl inet, OUT uss_index integer, OUT err_msg text);
       admin          postgres    false    9            w           1255    233004    deleteusers(integer[])    FUNCTION     �  CREATE FUNCTION admin.deleteusers(del_indexes integer[]) RETURNS integer
    LANGUAGE plpgsql
    AS $$
declare delrows integer;
begin
	delete from admin.userroles where coalesce(array_position(del_indexes, user_index),0)>0;
	with x as (delete from admin.users where coalesce(array_position(del_indexes, user_index),0)>0
			    returning user_index)
	select count(*) into delrows from x;
	return delrows;	
end;
$$;
 8   DROP FUNCTION admin.deleteusers(del_indexes integer[]);
       admin          postgres    false    9            s           1255    232994    get_all_roles_list()    FUNCTION     (  CREATE FUNCTION admin.get_all_roles_list() RETURNS json
    LANGUAGE plpgsql
    AS $$
declare res json;
begin
select json_agg(json_build_object('role_index', role_index,
								  'role_name', role_name, 'role_fullname', role_fullname))
								  into res
from admin.roles;
return res;
end;
$$;
 *   DROP FUNCTION admin.get_all_roles_list();
       admin          postgres    false    9            z           1255    233420    get_basic_resources(integer)    FUNCTION     s  CREATE FUNCTION admin.get_basic_resources(irole_index integer) RETURNS refcursor
    LANGUAGE plpgsql
    AS $$
declare res refcursor;
begin
open res for
with recursive x as (
	select r.res_index, r.res_name 
	from admin.resources r, admin.funcblockresources b, admin.funcblockroles f, admin.resourcetypes t
	where r.res_index=b.res_index and b.fb_index = f.fb_index and f.role_index =irole_index
	and r.res_res_index is null and r.rtp_index = t.rtp_index and t.is_visible = false
	union
		select r.res_index, r.res_name 
	from admin.resources r, x, admin.funcblockresources b, admin.funcblockroles f, admin.resourcetypes t
	where r.res_index=b.res_index and b.fb_index = f.fb_index and f.role_index =irole_index
	and r.res_res_index =x.res_index and r.rtp_index = t.rtp_index and t.is_visible = false
	and t.rtp_name='MainMenuComp')
	select res_name from x;
	
	return res;
end;
$$;
 >   DROP FUNCTION admin.get_basic_resources(irole_index integer);
       admin          postgres    false    9            o           1255    232985    get_department_tree(integer)    FUNCTION     �  CREATE FUNCTION admin.get_department_tree(idep_index integer) RETURNS refcursor
    LANGUAGE plpgsql
    AS $$
declare res refcursor;
begin
open res for 
	select dep_index, dep_name from(
	select dep_index, dep_name, rn from admin.dep_tree
	union  
	select -1 as dep_index, '------No departiment----' as dep_name, 0 as rn) a
	order by dep_index = idep_index desc, rn;
return res;
end;
$$;
 =   DROP FUNCTION admin.get_department_tree(idep_index integer);
       admin          postgres    false    9            q           1255    232991 !   get_department_tree_json(integer)    FUNCTION     �  CREATE FUNCTION admin.get_department_tree_json(idep_index integer) RETURNS json
    LANGUAGE plpgsql
    AS $$
declare res json;
begin
	select json_agg(json_build_object('dep_index', dep_index, 'dep_name', dep_name)) 
	into res from(select *from (
	select dep_index, dep_name, rn from admin.dep_tree
	union  
	select -1 as dep_index, '------No departiment----' as dep_name, 0 as rn ) b
	order by dep_index = idep_index desc, rn) a;	
return res;
end;
$$;
 B   DROP FUNCTION admin.get_department_tree_json(idep_index integer);
       admin          postgres    false    9            p           1255    232976     get_json_fulldata(text, integer)    FUNCTION     �  CREATE FUNCTION admin.get_json_fulldata(iuser_login text, irole_index integer) RETURNS json
    LANGUAGE plpgsql
    AS $$
declare res json;
begin
select json_build_object('User',json_build_object('user_index', u.user_index, 'user_login', user_login,
						  'dep_index', u.dep_index, 'dep_name', dep_name, 'user_properties', user_properties) ,
						 'Role', json_build_object('role_index', r.role_index, 
						'role_name', role_name, 'role_fullname', role_fullname)) into res
from admin.users u inner join admin.roles r on user_login = iuser_login and r.role_index = irole_index 
inner join  admin.userroles x on r.role_index = x.role_index and u.user_index = x.user_index
left join admin.departments d on u.dep_index = d.dep_index;
return res;
end;
$$;
 N   DROP FUNCTION admin.get_json_fulldata(iuser_login text, irole_index integer);
       admin          postgres    false    9            n           1255    232961 "   get_resource_access(integer, text)    FUNCTION     �  CREATE FUNCTION admin.get_resource_access(irole_index integer, ires_name text) RETURNS boolean
    LANGUAGE plpgsql
    AS $$
begin
if exists(
select s.res_name
	from admin.resources s,  admin.funcblockresources b, admin.funcblockroles f where
	s.res_index = b.res_index and f.fb_index= b.fb_index and f.role_index =irole_index and
	trim(upper(s.res_name))=trim(upper(ires_name))) then return true;
	else return false;
	end if;
end;
$$;
 N   DROP FUNCTION admin.get_resource_access(irole_index integer, ires_name text);
       admin          postgres    false    9            \           1255    232972 ,   get_resource_access_childlist(integer, text)    FUNCTION       CREATE FUNCTION admin.get_resource_access_childlist(irole_index integer, ires_name text) RETURNS refcursor
    LANGUAGE plpgsql
    AS $$
declare res refcursor;
begin
open res for 
with recursive r as (
select s.res_index, s.res_name 
	from admin.resources s, admin.resources u,  admin.funcblockresources b, admin.funcblockroles f where
	s.res_index = b.res_index and f.fb_index= b.fb_index and f.role_index =irole_index and
	trim(upper(u.res_name))=trim(upper(ires_name)) and s.res_res_index = u.res_index
union
	select s.res_index, s.res_name
	from 	admin.resources s, r,  admin.funcblockresources b, admin.funcblockroles f where
	s.res_index = b.res_index and f.fb_index= b.fb_index and f.role_index = irole_index and
	s.res_res_index = r.res_index
)
select res_name from r;
return res;
end;
$$;
 X   DROP FUNCTION admin.get_resource_access_childlist(irole_index integer, ires_name text);
       admin          postgres    false    9            l           1255    232956    get_user_index(text)    FUNCTION     �   CREATE FUNCTION admin.get_user_index(iuser_login text) RETURNS integer
    LANGUAGE plpgsql
    AS $_$
declare iuser_index integer;
begin
select user_index into iuser_index from admin.users where user_login = $1;
return iuser_index;
end;
$_$;
 6   DROP FUNCTION admin.get_user_index(iuser_login text);
       admin          postgres    false    9            r           1255    232992    get_userlist_json()    FUNCTION     �  CREATE FUNCTION admin.get_userlist_json() RETURNS json
    LANGUAGE plpgsql
    AS $$
declare res json;
begin
	select json_agg(json_build_object('user_index', user_index, 'user_login', user_login, 
							'dep_index', dep_index, 'user_properties', user_properties::json)) 
	into res from(select * from(
	select user_index, user_login, dep_index, user_properties::text from admin.users
	union  
	select -1 as user_index, '------No user selected----' , -1,  '{}') b order by user_index
) a;	
return res;
end;
$$;
 )   DROP FUNCTION admin.get_userlist_json();
       admin          postgres    false    9            k           1255    232953    get_userrolelist(integer)    FUNCTION     �  CREATE FUNCTION admin.get_userrolelist(iuser_index integer) RETURNS json
    LANGUAGE plpgsql
    AS $$
 declare res json;
begin
	select json_agg(json_build_object('role_index', r.role_index, 'role_name', r.role_name, 'role_fullname', r.role_fullname ))
	into res
	from admin.roles r, admin.userroles u 
	where u.user_index = iuser_index and u.role_index = r.role_index;	
	return res;
end;
$$;
 ;   DROP FUNCTION admin.get_userrolelist(iuser_index integer);
       admin          postgres    false    9            j           1255    232954    get_userrolelist(text)    FUNCTION     �  CREATE FUNCTION admin.get_userrolelist(iuser_login text) RETURNS json
    LANGUAGE plpgsql
    AS $$
 declare res json;
begin
	select json_agg(json_build_object('role_index', r.role_index, 'role_name', r.role_name, 'role_fullname', r.role_fullname ))
	into res
	from admin.roles r, admin.userroles u , admin.users a
	where a.user_login = iuser_login and u.role_index = r.role_index and a.user_index = u.user_index;	
	return res;
end;
$$;
 8   DROP FUNCTION admin.get_userrolelist(iuser_login text);
       admin          postgres    false    9            |           1255    233631    get_userrolenolist(text)    FUNCTION     �  CREATE FUNCTION admin.get_userrolenolist(iuser_login text) RETURNS json
    LANGUAGE plpgsql
    AS $$
declare res json;
begin
	select json_agg(json_build_object('role_index', r.role_index, 'role_name', r.role_name, 'role_fullname', r.role_fullname ))
	into res
	from admin.roles r
	where r.role_index not in (select u.role_index from admin.userroles u, admin.users a 
							   where  a.user_login = iuser_login and a.user_index = u.user_index  ) ;	
	return res;
end;
$$;
 :   DROP FUNCTION admin.get_userrolenolist(iuser_login text);
       admin          postgres    false    9            t           1255    232997    register_user(json)    FUNCTION     �  CREATE FUNCTION admin.register_user(ijson json, OUT user_index integer, OUT err_msg text) RETURNS record
    LANGUAGE plpgsql
    AS $$
declare
newuserinfo record;
begin
user_index = -1;
newuserinfo =admin.add_user(ijson->>'user_login', ijson->>'user_password',(ijson->>'dep_index')::integer,
						   ijson->'user_properties');
					
if coalesce(newuserinfo.err_msg	,'')!='' then err_msg =newuserinfo.err_msg;  return; end if; 				 
					 
select string_agg(admin.add_userrole(newuserinfo.user_index, r::integer), ' ') into err_msg
from  json_array_elements_text(ijson->'role_list') r;

user_index=newuserinfo.user_index;
return;
end;
$$;
 Y   DROP FUNCTION admin.register_user(ijson json, OUT user_index integer, OUT err_msg text);
       admin          postgres    false    9            u           1255    233000    upd_userrole_json(json)    FUNCTION     �  CREATE FUNCTION admin.upd_userrole_json(ijson json, OUT insrows integer, OUT delrows integer) RETURNS record
    LANGUAGE plpgsql
    AS $$
declare 
datarows integer;
begin
select count (*) into datarows from json_array_elements_text(ijson->'role_list');
if datarows!=0 then													
	with NewData as ( select (ijson->>'user_index')::integer user_index, r::integer role_index
				  from json_array_elements_text(ijson->'role_list') r),
	ins as (insert into admin.userroles as u (user_index, role_index)
		   select user_index, role_index from NewData
		   on conflict (user_index, role_index) do nothing
		   returning u.role_index as insrows),
	del as (delete from admin.userroles u  using NewData n 
			where u.user_index = n.user_index and u.role_index 
			not in (select role_index from NewData)
		   returning u.role_index as delrows) ,
	insr as (select count(*) cins  from ins),
	delr as (select count(*) cdel  from del)
	select cins, cdel into insrows, delrows from insr, delr;	
else
with del as (
	delete from admin.userroles where user_index = (ijson->>'user_index')::integer
	returning role_index as delrows)
	select count(*) into delrows from del;
	insrows = 0;
end if;
end;
$$;
 ]   DROP FUNCTION admin.upd_userrole_json(ijson json, OUT insrows integer, OUT delrows integer);
       admin          postgres    false    9            �            1259    232698    departments    TABLE     �   CREATE TABLE admin.departments (
    dep_index integer NOT NULL,
    dep_dep_index integer,
    dep_name text NOT NULL,
    dep_properties json,
    dep_nn integer
);
    DROP TABLE admin.departments;
       admin            postgres    false    9            �           0    0    TABLE departments    COMMENT     >   COMMENT ON TABLE admin.departments IS 'Table of departments';
          admin          postgres    false    203            �           0    0    COLUMN departments.dep_index    COMMENT     H   COMMENT ON COLUMN admin.departments.dep_index IS 'Index of department';
          admin          postgres    false    203            �           0    0     COLUMN departments.dep_dep_index    COMMENT     S   COMMENT ON COLUMN admin.departments.dep_dep_index IS 'Index of parent department';
          admin          postgres    false    203            �           0    0    COLUMN departments.dep_name    COMMENT     F   COMMENT ON COLUMN admin.departments.dep_name IS 'Name of department';
          admin          postgres    false    203            �           0    0 !   COLUMN departments.dep_properties    COMMENT     f   COMMENT ON COLUMN admin.departments.dep_properties IS 'List for additional properties of department';
          admin          postgres    false    203            �            1259    232977    dep_tree    VIEW     �  CREATE VIEW admin.dep_tree AS
 WITH RECURSIVE r AS (
         SELECT departments.dep_index,
            departments.dep_name,
            1 AS lev,
            ARRAY[departments.dep_nn] AS path
           FROM admin.departments
          WHERE (departments.dep_dep_index IS NULL)
        UNION
         SELECT x.dep_index,
            x.dep_name,
            (1 + r_1.lev) AS lev,
            (r_1.path || x.dep_nn) AS path
           FROM admin.departments x,
            r r_1
          WHERE (x.dep_dep_index = r_1.dep_index)
        )
 SELECT r.dep_index,
    lpad(r.dep_name, ((5 * (r.lev - 1)) + length(r.dep_name))) AS dep_name,
    row_number() OVER (ORDER BY r.path) AS rn
   FROM r
  ORDER BY r.path;
    DROP VIEW admin.dep_tree;
       admin          postgres    false    203    203    203    203    9            �            1259    232696    departments_dep_index_seq    SEQUENCE     �   CREATE SEQUENCE admin.departments_dep_index_seq
    AS integer
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;
 /   DROP SEQUENCE admin.departments_dep_index_seq;
       admin          postgres    false    9    203            �           0    0    departments_dep_index_seq    SEQUENCE OWNED BY     U   ALTER SEQUENCE admin.departments_dep_index_seq OWNED BY admin.departments.dep_index;
          admin          postgres    false    202            �            1259    232822    funcblockresources    TABLE     i   CREATE TABLE admin.funcblockresources (
    fb_index integer NOT NULL,
    res_index integer NOT NULL
);
 %   DROP TABLE admin.funcblockresources;
       admin            postgres    false    9            �           0    0    TABLE funcblockresources    COMMENT     l   COMMENT ON TABLE admin.funcblockresources IS 'Corresponding table between functional blocks and resources';
          admin          postgres    false    216            �           0    0 "   COLUMN funcblockresources.fb_index    COMMENT     T   COMMENT ON COLUMN admin.funcblockresources.fb_index IS 'Index of functional block';
          admin          postgres    false    216            �           0    0 #   COLUMN funcblockresources.res_index    COMMENT     M   COMMENT ON COLUMN admin.funcblockresources.res_index IS 'Index of resource';
          admin          postgres    false    216            �            1259    232807    funcblockroles    TABLE     f   CREATE TABLE admin.funcblockroles (
    fb_index integer NOT NULL,
    role_index integer NOT NULL
);
 !   DROP TABLE admin.funcblockroles;
       admin            postgres    false    9            �           0    0    TABLE funcblockroles    COMMENT     d   COMMENT ON TABLE admin.funcblockroles IS 'Corresponding table between functional blocks and roles';
          admin          postgres    false    215            �           0    0    COLUMN funcblockroles.fb_index    COMMENT     P   COMMENT ON COLUMN admin.funcblockroles.fb_index IS 'Index of functional block';
          admin          postgres    false    215            �           0    0     COLUMN funcblockroles.role_index    COMMENT     F   COMMENT ON COLUMN admin.funcblockroles.role_index IS 'Index of role';
          admin          postgres    false    215            �            1259    232796 
   funcblocks    TABLE     |   CREATE TABLE admin.funcblocks (
    fb_index integer NOT NULL,
    fb_name text,
    fb_fullname text,
    fb_nn integer
);
    DROP TABLE admin.funcblocks;
       admin            postgres    false    9            �           0    0    TABLE funcblocks    COMMENT     E   COMMENT ON TABLE admin.funcblocks IS 'Table of blocks of functions';
          admin          postgres    false    214            �           0    0    COLUMN funcblocks.fb_index    COMMENT     A   COMMENT ON COLUMN admin.funcblocks.fb_index IS 'Index of block';
          admin          postgres    false    214            �           0    0    COLUMN funcblocks.fb_name    COMMENT     ?   COMMENT ON COLUMN admin.funcblocks.fb_name IS 'Name of block';
          admin          postgres    false    214            �           0    0    COLUMN funcblocks.fb_fullname    COMMENT     H   COMMENT ON COLUMN admin.funcblocks.fb_fullname IS 'Full name of block';
          admin          postgres    false    214            �            1259    232794    funcblocks_fb_index_seq    SEQUENCE     �   CREATE SEQUENCE admin.funcblocks_fb_index_seq
    AS integer
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;
 -   DROP SEQUENCE admin.funcblocks_fb_index_seq;
       admin          postgres    false    214    9            �           0    0    funcblocks_fb_index_seq    SEQUENCE OWNED BY     Q   ALTER SEQUENCE admin.funcblocks_fb_index_seq OWNED BY admin.funcblocks.fb_index;
          admin          postgres    false    213            �            1259    232773 	   resources    TABLE     �   CREATE TABLE admin.resources (
    res_index integer NOT NULL,
    res_res_index integer,
    res_name text NOT NULL,
    res_fullname text,
    rtp_index integer,
    res_nn integer
);
    DROP TABLE admin.resources;
       admin            postgres    false    9            �           0    0    TABLE resources    COMMENT     :   COMMENT ON TABLE admin.resources IS 'Table of resources';
          admin          postgres    false    212            �           0    0    COLUMN resources.res_index    COMMENT     D   COMMENT ON COLUMN admin.resources.res_index IS 'Index of resource';
          admin          postgres    false    212            �           0    0    COLUMN resources.res_res_index    COMMENT     O   COMMENT ON COLUMN admin.resources.res_res_index IS 'Index of parent resource';
          admin          postgres    false    212            �           0    0    COLUMN resources.res_name    COMMENT     B   COMMENT ON COLUMN admin.resources.res_name IS 'Name of resource';
          admin          postgres    false    212            �           0    0    COLUMN resources.res_fullname    COMMENT     K   COMMENT ON COLUMN admin.resources.res_fullname IS 'Full name of resource';
          admin          postgres    false    212            �           0    0    COLUMN resources.rtp_index    COMMENT     L   COMMENT ON COLUMN admin.resources.rtp_index IS 'Index of type of resource';
          admin          postgres    false    212            �            1259    232771    resources_res_index_seq    SEQUENCE     �   CREATE SEQUENCE admin.resources_res_index_seq
    AS integer
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;
 -   DROP SEQUENCE admin.resources_res_index_seq;
       admin          postgres    false    9    212            �           0    0    resources_res_index_seq    SEQUENCE OWNED BY     Q   ALTER SEQUENCE admin.resources_res_index_seq OWNED BY admin.resources.res_index;
          admin          postgres    false    211            �            1259    232760    resourcetypes    TABLE     �   CREATE TABLE admin.resourcetypes (
    rtp_index integer NOT NULL,
    rtp_name text NOT NULL,
    rtp_fullname text,
    is_visible boolean,
    rtp_nn integer
);
     DROP TABLE admin.resourcetypes;
       admin            postgres    false    9            �           0    0    TABLE resourcetypes    COMMENT     G   COMMENT ON TABLE admin.resourcetypes IS 'Table of types of resources';
          admin          postgres    false    210            �           0    0    COLUMN resourcetypes.rtp_index    COMMENT     D   COMMENT ON COLUMN admin.resourcetypes.rtp_index IS 'Index of type';
          admin          postgres    false    210            �           0    0    COLUMN resourcetypes.rtp_name    COMMENT     B   COMMENT ON COLUMN admin.resourcetypes.rtp_name IS 'Name of type';
          admin          postgres    false    210            �           0    0 !   COLUMN resourcetypes.rtp_fullname    COMMENT     K   COMMENT ON COLUMN admin.resourcetypes.rtp_fullname IS 'Full name of type';
          admin          postgres    false    210            �            1259    232758    resourcetypes_rtp_index_seq    SEQUENCE     �   CREATE SEQUENCE admin.resourcetypes_rtp_index_seq
    AS integer
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;
 1   DROP SEQUENCE admin.resourcetypes_rtp_index_seq;
       admin          postgres    false    9    210            �           0    0    resourcetypes_rtp_index_seq    SEQUENCE OWNED BY     Y   ALTER SEQUENCE admin.resourcetypes_rtp_index_seq OWNED BY admin.resourcetypes.rtp_index;
          admin          postgres    false    209            �            1259    232732    roles    TABLE     �   CREATE TABLE admin.roles (
    role_index integer NOT NULL,
    role_name text NOT NULL,
    role_fullname text,
    role_nn integer
);
    DROP TABLE admin.roles;
       admin            postgres    false    9            �           0    0    TABLE roles    COMMENT     2   COMMENT ON TABLE admin.roles IS 'Table of roles';
          admin          postgres    false    207            �           0    0    COLUMN roles.role_index    COMMENT     =   COMMENT ON COLUMN admin.roles.role_index IS 'Index of role';
          admin          postgres    false    207            �           0    0    COLUMN roles.role_name    COMMENT     ;   COMMENT ON COLUMN admin.roles.role_name IS 'Name of role';
          admin          postgres    false    207            �           0    0    COLUMN roles.role_fullname    COMMENT     D   COMMENT ON COLUMN admin.roles.role_fullname IS 'Full name of role';
          admin          postgres    false    207            �            1259    232730    roles_role_index_seq    SEQUENCE     �   CREATE SEQUENCE admin.roles_role_index_seq
    AS integer
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;
 *   DROP SEQUENCE admin.roles_role_index_seq;
       admin          postgres    false    9    207            �           0    0    roles_role_index_seq    SEQUENCE OWNED BY     K   ALTER SEQUENCE admin.roles_role_index_seq OWNED BY admin.roles.role_index;
          admin          postgres    false    206            �            1259    232743 	   userroles    TABLE     c   CREATE TABLE admin.userroles (
    user_index integer NOT NULL,
    role_index integer NOT NULL
);
    DROP TABLE admin.userroles;
       admin            postgres    false    9            �           0    0    TABLE userroles    COMMENT     S   COMMENT ON TABLE admin.userroles IS 'Corresponding table between users and roles';
          admin          postgres    false    208            �           0    0    COLUMN userroles.user_index    COMMENT     A   COMMENT ON COLUMN admin.userroles.user_index IS 'Index of user';
          admin          postgres    false    208            �           0    0    COLUMN userroles.role_index    COMMENT     A   COMMENT ON COLUMN admin.userroles.role_index IS 'Index of role';
          admin          postgres    false    208            �            1259    232714    users    TABLE     �   CREATE TABLE admin.users (
    user_index integer NOT NULL,
    dep_index integer,
    user_login text NOT NULL,
    user_password text NOT NULL,
    user_properties json,
    user_nn integer
);
    DROP TABLE admin.users;
       admin            postgres    false    9            �           0    0    TABLE users    COMMENT     2   COMMENT ON TABLE admin.users IS 'Table of users';
          admin          postgres    false    205            �           0    0    COLUMN users.user_index    COMMENT     =   COMMENT ON COLUMN admin.users.user_index IS 'Index of user';
          admin          postgres    false    205            �           0    0    COLUMN users.dep_index    COMMENT     A   COMMENT ON COLUMN admin.users.dep_index IS 'User''s department';
          admin          postgres    false    205            �           0    0    COLUMN users.user_login    COMMENT     5   COMMENT ON COLUMN admin.users.user_login IS 'Login';
          admin          postgres    false    205            �           0    0    COLUMN users.user_password    COMMENT     ;   COMMENT ON COLUMN admin.users.user_password IS 'Password';
          admin          postgres    false    205            �           0    0    COLUMN users.user_properties    COMMENT     [   COMMENT ON COLUMN admin.users.user_properties IS 'List for additional properties of user';
          admin          postgres    false    205            �            1259    232712    users_user_index_seq    SEQUENCE     �   CREATE SEQUENCE admin.users_user_index_seq
    AS integer
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;
 *   DROP SEQUENCE admin.users_user_index_seq;
       admin          postgres    false    9    205            �           0    0    users_user_index_seq    SEQUENCE OWNED BY     K   ALTER SEQUENCE admin.users_user_index_seq OWNED BY admin.users.user_index;
          admin          postgres    false    204            �            1259    232839    usersessions    TABLE     �   CREATE TABLE admin.usersessions (
    uss_index integer NOT NULL,
    user_index integer NOT NULL,
    role_index integer NOT NULL,
    date_beg timestamp without time zone NOT NULL,
    date_end timestamp without time zone,
    uss_url inet
);
    DROP TABLE admin.usersessions;
       admin            postgres    false    9            �           0    0    TABLE usersessions    COMMENT     <   COMMENT ON TABLE admin.usersessions IS 'Table of sessions';
          admin          postgres    false    218            �           0    0    COLUMN usersessions.uss_index    COMMENT     F   COMMENT ON COLUMN admin.usersessions.uss_index IS 'Index of session';
          admin          postgres    false    218            �           0    0    COLUMN usersessions.user_index    COMMENT     D   COMMENT ON COLUMN admin.usersessions.user_index IS 'Index of user';
          admin          postgres    false    218            �           0    0    COLUMN usersessions.role_index    COMMENT     D   COMMENT ON COLUMN admin.usersessions.role_index IS 'Index of role';
          admin          postgres    false    218            �           0    0    COLUMN usersessions.date_beg    COMMENT     Q   COMMENT ON COLUMN admin.usersessions.date_beg IS 'Starting time of the session';
          admin          postgres    false    218            �           0    0    COLUMN usersessions.date_end    COMMENT     R   COMMENT ON COLUMN admin.usersessions.date_end IS 'Finishing time of the session';
          admin          postgres    false    218            �           0    0    COLUMN usersessions.uss_url    COMMENT     ?   COMMENT ON COLUMN admin.usersessions.uss_url IS 'User''s URL';
          admin          postgres    false    218            �            1259    232837    usersessions_uss_index_seq    SEQUENCE     �   CREATE SEQUENCE admin.usersessions_uss_index_seq
    AS integer
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;
 0   DROP SEQUENCE admin.usersessions_uss_index_seq;
       admin          postgres    false    9    218            �           0    0    usersessions_uss_index_seq    SEQUENCE OWNED BY     W   ALTER SEQUENCE admin.usersessions_uss_index_seq OWNED BY admin.usersessions.uss_index;
          admin          postgres    false    217            �           2604    232701    departments dep_index    DEFAULT     |   ALTER TABLE ONLY admin.departments ALTER COLUMN dep_index SET DEFAULT nextval('admin.departments_dep_index_seq'::regclass);
 C   ALTER TABLE admin.departments ALTER COLUMN dep_index DROP DEFAULT;
       admin          postgres    false    203    202    203            �           2604    232799    funcblocks fb_index    DEFAULT     x   ALTER TABLE ONLY admin.funcblocks ALTER COLUMN fb_index SET DEFAULT nextval('admin.funcblocks_fb_index_seq'::regclass);
 A   ALTER TABLE admin.funcblocks ALTER COLUMN fb_index DROP DEFAULT;
       admin          postgres    false    214    213    214            �           2604    232776    resources res_index    DEFAULT     x   ALTER TABLE ONLY admin.resources ALTER COLUMN res_index SET DEFAULT nextval('admin.resources_res_index_seq'::regclass);
 A   ALTER TABLE admin.resources ALTER COLUMN res_index DROP DEFAULT;
       admin          postgres    false    211    212    212            �           2604    232763    resourcetypes rtp_index    DEFAULT     �   ALTER TABLE ONLY admin.resourcetypes ALTER COLUMN rtp_index SET DEFAULT nextval('admin.resourcetypes_rtp_index_seq'::regclass);
 E   ALTER TABLE admin.resourcetypes ALTER COLUMN rtp_index DROP DEFAULT;
       admin          postgres    false    210    209    210            �           2604    232735    roles role_index    DEFAULT     r   ALTER TABLE ONLY admin.roles ALTER COLUMN role_index SET DEFAULT nextval('admin.roles_role_index_seq'::regclass);
 >   ALTER TABLE admin.roles ALTER COLUMN role_index DROP DEFAULT;
       admin          postgres    false    207    206    207            �           2604    232717    users user_index    DEFAULT     r   ALTER TABLE ONLY admin.users ALTER COLUMN user_index SET DEFAULT nextval('admin.users_user_index_seq'::regclass);
 >   ALTER TABLE admin.users ALTER COLUMN user_index DROP DEFAULT;
       admin          postgres    false    205    204    205            �           2604    232842    usersessions uss_index    DEFAULT     ~   ALTER TABLE ONLY admin.usersessions ALTER COLUMN uss_index SET DEFAULT nextval('admin.usersessions_uss_index_seq'::regclass);
 D   ALTER TABLE admin.usersessions ALTER COLUMN uss_index DROP DEFAULT;
       admin          postgres    false    218    217    218            �          0    232698    departments 
   TABLE DATA           `   COPY admin.departments (dep_index, dep_dep_index, dep_name, dep_properties, dep_nn) FROM stdin;
    admin          postgres    false    203   �       �          0    232822    funcblockresources 
   TABLE DATA           @   COPY admin.funcblockresources (fb_index, res_index) FROM stdin;
    admin          postgres    false    216   ��       �          0    232807    funcblockroles 
   TABLE DATA           =   COPY admin.funcblockroles (fb_index, role_index) FROM stdin;
    admin          postgres    false    215   "�       �          0    232796 
   funcblocks 
   TABLE DATA           J   COPY admin.funcblocks (fb_index, fb_name, fb_fullname, fb_nn) FROM stdin;
    admin          postgres    false    214   I�       �          0    232773 	   resources 
   TABLE DATA           g   COPY admin.resources (res_index, res_res_index, res_name, res_fullname, rtp_index, res_nn) FROM stdin;
    admin          postgres    false    212   ��       �          0    232760    resourcetypes 
   TABLE DATA           ]   COPY admin.resourcetypes (rtp_index, rtp_name, rtp_fullname, is_visible, rtp_nn) FROM stdin;
    admin          postgres    false    210   Y�       �          0    232732    roles 
   TABLE DATA           M   COPY admin.roles (role_index, role_name, role_fullname, role_nn) FROM stdin;
    admin          postgres    false    207    �       �          0    232743 	   userroles 
   TABLE DATA           :   COPY admin.userroles (user_index, role_index) FROM stdin;
    admin          postgres    false    208   ;�       �          0    232714    users 
   TABLE DATA           j   COPY admin.users (user_index, dep_index, user_login, user_password, user_properties, user_nn) FROM stdin;
    admin          postgres    false    205   z�       �          0    232839    usersessions 
   TABLE DATA           e   COPY admin.usersessions (uss_index, user_index, role_index, date_beg, date_end, uss_url) FROM stdin;
    admin          postgres    false    218   ��       �           0    0    departments_dep_index_seq    SEQUENCE SET     F   SELECT pg_catalog.setval('admin.departments_dep_index_seq', 4, true);
          admin          postgres    false    202            �           0    0    funcblocks_fb_index_seq    SEQUENCE SET     D   SELECT pg_catalog.setval('admin.funcblocks_fb_index_seq', 3, true);
          admin          postgres    false    213            �           0    0    resources_res_index_seq    SEQUENCE SET     E   SELECT pg_catalog.setval('admin.resources_res_index_seq', 29, true);
          admin          postgres    false    211            �           0    0    resourcetypes_rtp_index_seq    SEQUENCE SET     H   SELECT pg_catalog.setval('admin.resourcetypes_rtp_index_seq', 7, true);
          admin          postgres    false    209            �           0    0    roles_role_index_seq    SEQUENCE SET     A   SELECT pg_catalog.setval('admin.roles_role_index_seq', 3, true);
          admin          postgres    false    206            �           0    0    users_user_index_seq    SEQUENCE SET     B   SELECT pg_catalog.setval('admin.users_user_index_seq', 57, true);
          admin          postgres    false    204            �           0    0    usersessions_uss_index_seq    SEQUENCE SET     J   SELECT pg_catalog.setval('admin.usersessions_uss_index_seq', 2117, true);
          admin          postgres    false    217            �           2606    232706    departments dep_pkey 
   CONSTRAINT     X   ALTER TABLE ONLY admin.departments
    ADD CONSTRAINT dep_pkey PRIMARY KEY (dep_index);
 =   ALTER TABLE ONLY admin.departments DROP CONSTRAINT dep_pkey;
       admin            postgres    false    203                       2606    232804    funcblocks fb_pkey 
   CONSTRAINT     U   ALTER TABLE ONLY admin.funcblocks
    ADD CONSTRAINT fb_pkey PRIMARY KEY (fb_index);
 ;   ALTER TABLE ONLY admin.funcblocks DROP CONSTRAINT fb_pkey;
       admin            postgres    false    214                       2606    232826    funcblockresources fbres_pkey 
   CONSTRAINT     k   ALTER TABLE ONLY admin.funcblockresources
    ADD CONSTRAINT fbres_pkey PRIMARY KEY (fb_index, res_index);
 F   ALTER TABLE ONLY admin.funcblockresources DROP CONSTRAINT fbres_pkey;
       admin            postgres    false    216    216                       2606    232811    funcblockroles fbrole_pkey 
   CONSTRAINT     i   ALTER TABLE ONLY admin.funcblockroles
    ADD CONSTRAINT fbrole_pkey PRIMARY KEY (fb_index, role_index);
 C   ALTER TABLE ONLY admin.funcblockroles DROP CONSTRAINT fbrole_pkey;
       admin            postgres    false    215    215                       2606    232806 %   funcblocks funcblocks_fb_fullname_key 
   CONSTRAINT     f   ALTER TABLE ONLY admin.funcblocks
    ADD CONSTRAINT funcblocks_fb_fullname_key UNIQUE (fb_fullname);
 N   ALTER TABLE ONLY admin.funcblocks DROP CONSTRAINT funcblocks_fb_fullname_key;
       admin            postgres    false    214            	           2606    232781    resources res_pkey 
   CONSTRAINT     V   ALTER TABLE ONLY admin.resources
    ADD CONSTRAINT res_pkey PRIMARY KEY (res_index);
 ;   ALTER TABLE ONLY admin.resources DROP CONSTRAINT res_pkey;
       admin            postgres    false    212                       2606    232783 $   resources resources_res_fullname_key 
   CONSTRAINT     f   ALTER TABLE ONLY admin.resources
    ADD CONSTRAINT resources_res_fullname_key UNIQUE (res_fullname);
 M   ALTER TABLE ONLY admin.resources DROP CONSTRAINT resources_res_fullname_key;
       admin            postgres    false    212                       2606    232770 ,   resourcetypes resourcetypes_rtp_fullname_key 
   CONSTRAINT     n   ALTER TABLE ONLY admin.resourcetypes
    ADD CONSTRAINT resourcetypes_rtp_fullname_key UNIQUE (rtp_fullname);
 U   ALTER TABLE ONLY admin.resourcetypes DROP CONSTRAINT resourcetypes_rtp_fullname_key;
       admin            postgres    false    210            �           2606    232740    roles role_pkey 
   CONSTRAINT     T   ALTER TABLE ONLY admin.roles
    ADD CONSTRAINT role_pkey PRIMARY KEY (role_index);
 8   ALTER TABLE ONLY admin.roles DROP CONSTRAINT role_pkey;
       admin            postgres    false    207                       2606    232742    roles roles_role_fullname_key 
   CONSTRAINT     `   ALTER TABLE ONLY admin.roles
    ADD CONSTRAINT roles_role_fullname_key UNIQUE (role_fullname);
 F   ALTER TABLE ONLY admin.roles DROP CONSTRAINT roles_role_fullname_key;
       admin            postgres    false    207                       2606    232768    resourcetypes rtp_pkey 
   CONSTRAINT     Z   ALTER TABLE ONLY admin.resourcetypes
    ADD CONSTRAINT rtp_pkey PRIMARY KEY (rtp_index);
 ?   ALTER TABLE ONLY admin.resourcetypes DROP CONSTRAINT rtp_pkey;
       admin            postgres    false    210            �           2606    232722    users user_pkey 
   CONSTRAINT     T   ALTER TABLE ONLY admin.users
    ADD CONSTRAINT user_pkey PRIMARY KEY (user_index);
 8   ALTER TABLE ONLY admin.users DROP CONSTRAINT user_pkey;
       admin            postgres    false    205                       2606    232747    userroles userrole_pkey 
   CONSTRAINT     h   ALTER TABLE ONLY admin.userroles
    ADD CONSTRAINT userrole_pkey PRIMARY KEY (user_index, role_index);
 @   ALTER TABLE ONLY admin.userroles DROP CONSTRAINT userrole_pkey;
       admin            postgres    false    208    208            �           2606    232724    users users_user_login_key 
   CONSTRAINT     Z   ALTER TABLE ONLY admin.users
    ADD CONSTRAINT users_user_login_key UNIQUE (user_login);
 C   ALTER TABLE ONLY admin.users DROP CONSTRAINT users_user_login_key;
       admin            postgres    false    205                       2606    232847    usersessions uss_pkey 
   CONSTRAINT     Y   ALTER TABLE ONLY admin.usersessions
    ADD CONSTRAINT uss_pkey PRIMARY KEY (uss_index);
 >   ALTER TABLE ONLY admin.usersessions DROP CONSTRAINT uss_pkey;
       admin            postgres    false    218                       2606    232707    departments dep_fkey    FK CONSTRAINT     �   ALTER TABLE ONLY admin.departments
    ADD CONSTRAINT dep_fkey FOREIGN KEY (dep_dep_index) REFERENCES admin.departments(dep_index);
 =   ALTER TABLE ONLY admin.departments DROP CONSTRAINT dep_fkey;
       admin          postgres    false    203    203    3065                       2606    232827    funcblockresources fbres_f_fkey    FK CONSTRAINT     �   ALTER TABLE ONLY admin.funcblockresources
    ADD CONSTRAINT fbres_f_fkey FOREIGN KEY (fb_index) REFERENCES admin.funcblocks(fb_index);
 H   ALTER TABLE ONLY admin.funcblockresources DROP CONSTRAINT fbres_f_fkey;
       admin          postgres    false    216    214    3085                       2606    232832    funcblockresources fbres_r_fkey    FK CONSTRAINT     �   ALTER TABLE ONLY admin.funcblockresources
    ADD CONSTRAINT fbres_r_fkey FOREIGN KEY (res_index) REFERENCES admin.resources(res_index);
 H   ALTER TABLE ONLY admin.funcblockresources DROP CONSTRAINT fbres_r_fkey;
       admin          postgres    false    212    3081    216                       2606    232812    funcblockroles fbrole_f_fkey    FK CONSTRAINT     �   ALTER TABLE ONLY admin.funcblockroles
    ADD CONSTRAINT fbrole_f_fkey FOREIGN KEY (fb_index) REFERENCES admin.funcblocks(fb_index);
 E   ALTER TABLE ONLY admin.funcblockroles DROP CONSTRAINT fbrole_f_fkey;
       admin          postgres    false    215    3085    214                       2606    232817    funcblockroles fbrole_r_fkey    FK CONSTRAINT     �   ALTER TABLE ONLY admin.funcblockroles
    ADD CONSTRAINT fbrole_r_fkey FOREIGN KEY (role_index) REFERENCES admin.roles(role_index);
 E   ALTER TABLE ONLY admin.funcblockroles DROP CONSTRAINT fbrole_r_fkey;
       admin          postgres    false    3071    207    215                       2606    232784    resources res_rr_fkey    FK CONSTRAINT     �   ALTER TABLE ONLY admin.resources
    ADD CONSTRAINT res_rr_fkey FOREIGN KEY (res_res_index) REFERENCES admin.resources(res_index);
 >   ALTER TABLE ONLY admin.resources DROP CONSTRAINT res_rr_fkey;
       admin          postgres    false    212    212    3081                       2606    232789    resources res_rtp_fkey    FK CONSTRAINT     �   ALTER TABLE ONLY admin.resources
    ADD CONSTRAINT res_rtp_fkey FOREIGN KEY (rtp_index) REFERENCES admin.resourcetypes(rtp_index);
 ?   ALTER TABLE ONLY admin.resources DROP CONSTRAINT res_rtp_fkey;
       admin          postgres    false    210    3079    212                       2606    232725    users user_fkey    FK CONSTRAINT     {   ALTER TABLE ONLY admin.users
    ADD CONSTRAINT user_fkey FOREIGN KEY (dep_index) REFERENCES admin.departments(dep_index);
 8   ALTER TABLE ONLY admin.users DROP CONSTRAINT user_fkey;
       admin          postgres    false    205    3065    203                       2606    232753    userroles userrole_r_fkey    FK CONSTRAINT     �   ALTER TABLE ONLY admin.userroles
    ADD CONSTRAINT userrole_r_fkey FOREIGN KEY (role_index) REFERENCES admin.roles(role_index);
 B   ALTER TABLE ONLY admin.userroles DROP CONSTRAINT userrole_r_fkey;
       admin          postgres    false    3071    208    207                       2606    232748    userroles userrole_u_fkey    FK CONSTRAINT     �   ALTER TABLE ONLY admin.userroles
    ADD CONSTRAINT userrole_u_fkey FOREIGN KEY (user_index) REFERENCES admin.users(user_index);
 B   ALTER TABLE ONLY admin.userroles DROP CONSTRAINT userrole_u_fkey;
       admin          postgres    false    205    3067    208            !           2606    232853    usersessions uss_r_fkey    FK CONSTRAINT        ALTER TABLE ONLY admin.usersessions
    ADD CONSTRAINT uss_r_fkey FOREIGN KEY (role_index) REFERENCES admin.roles(role_index);
 @   ALTER TABLE ONLY admin.usersessions DROP CONSTRAINT uss_r_fkey;
       admin          postgres    false    3071    207    218                        2606    232848    usersessions uss_u_fkey    FK CONSTRAINT        ALTER TABLE ONLY admin.usersessions
    ADD CONSTRAINT uss_u_fkey FOREIGN KEY (user_index) REFERENCES admin.users(user_index);
 @   ALTER TABLE ONLY admin.usersessions DROP CONSTRAINT uss_u_fkey;
       admin          postgres    false    218    3067    205            �   >   x�3���I-.ц\Ɯ��%@�g�Rvj����RYbNi�R-P��$kbq��qqq $L�      �   E   x�˹�0�X,�0)��^��^���+�;�ٳy:!�,r��<�e�DADA��wH�մ      �      x�3�4�2�4b#�=... K      �   _   x�3�LL��̋/H�K�� �
��ɩ�řy�
9�y� �$_�L!7?%�3Ə˘3)�83Y!?)+5���5 5�/'G��8��8&�1F��� ur'�      �   �  x�e��n�0���)�l�n�ä��N����m��Tbo��N�t� ���W����q/X7?����.��?�"�z���eT�5=�0�W��޷{b�D��pc�C"�I9X0f�-�n������d��de@9���,=��PY��sɅ�r~�t�����XH��M�����2�J���4�c��Ac�Q�ѽ�tw�=�N�^��Zq��tZr���FG_��s��q����C�@���Ό����@01e$��F�L�iQ��������6���|��3Ut�Rߤ>Iն<!��nP�U���m�mC�PA -�^{k�V�N�7��~�$Ax��NY�VNMq�сē�/��V���w�sL�
�&��L� ����au(L��	�@x}�`�	fϪdlRb�8��f?�H�      �   �   x�M���0Dg�+�E	� $`h� [��r ��U�
��$$�����g]��,7Z�)���Q+�>�i��4���x����%�-_�J��^:����	ǯG��1>���Q�ԧ��mk�i'a�"��	�b�CF�k�PJ��?�      �   +   x�3�,I-.�/-N-���WHL������2��C�p�=... ���      �   /   x�3�4�2�4�2bs 61 �$l"L��L�@,3 +F��� �	R      �   9  x���]o�@���g��l�o��Y�ТV�&�AA>�S��_Flv�����C��>3��,�ե& ���Y	;�֥£dpmjKi�B�,2������d�_ć��͓Hp���ԣ���~�ǉ�h�2���xɔbH�-0�WB�5�rL���ga�qG�[W����w��KV8�}Qc��y�*��_�Dͅ���c�+YU������Х�8�eQ�]��=��e[�Eo���`n�B�yN��%�L�3T����O�z�̘�+E�fyN1��+H>���H�.�e��5^iEm�4�3}9��^�Ӻn����x4�f�=��۷ݾ��8��:��	��C�����Q��G��h��<��,�R�{Iϋz Tb�>Ze*�^�O�jx�[�涻NmȝO[��C7"��{�فƴ���^���«9ܯuձlv=�=����i��e�
���z:��c<��1�!����l�+�LM���?M�ս��#	��/�����>��g�ϩ�&~�������U��
�����H�DeKyf���#��O�������~Q�a�      �      x�m}ٵ$9��w����!�pI!���2�*`<U_n~�$��T�����H���M�W�[�#㏏�J�����?]���zS}���hM�P��c�=�/��Q��6lo�7��6�9�`�?ۺ,�~���?:?]��$�~F`>�M�T��`�i������O�&.�7���Ǔ�M���Y#���}^��ڟ���~���]zy^-�G䏭OW�oM�VK�t�8?{�$K�������M!�I[��a�oD��^mmqy����%�����F�����##�l}Z^ �?�c�����W T!�P N��/`����ѿ >��i��l��W��  >��e���Gz	�4�'��[	���?��B�0�%8����:�4Nc_���^�U���܂�2R[��4�����=G�ɟfz�ĥ�K~�e��Ǵk�����}�	�G<m�!/�㣶���>�(r^�A�ۚF�<N�x���m����N��՟$�d�Su��׍�c�G��)�'��q�l�'?���po����i+N��{������Zf������b݅N���z�h��sf(��O2>s���D�^�����c8}���Cɯ����VoJ�C��ό�m���+�Ud;-�`R`!� �9��؛N�"N�`�i#VQ[N{yҲ O`�5�v¤�u a��~$ZG0	�`2�V �bZ[��N��2 N������/��a3⬥�W{]��,⤵E�^/A�:
��C���_/A{X�G��\� ���4��5>ٖ����,���f�� ���K���0�/dHSۚo���C�`� �����H��XP���7=����P�!�Ƃ������У�p]w�Ta �����s����Y�Y�P��;�3z�L�G
3{�ѶY�xa��u;H�mt�v���	����_�=ORJ�O 1�Q_�7t 6��8R��*�7tX�;Z��z�Kн㐉3�Ȩ
���t�t���~��Zr�#�-��pSR�qR� x�OXP�u��b} 4}���.�ء/@�a�e�ԕ�~Rɬ��0	�VLxb��416�Z)4ql7~�N�������h�u�4 ~O�1k�Kw�t ³
_O�;)��I� ��.^��Z�$iI:$�ܮ[�_�$-��������m����yV�� ��N'9H���v��4L��ʀ�8��Z�yV�L�>�#I�� ����nVb�YK+4���0���8�']���K�'l�%�@h�0|��g>�1.��6Z1�^��wZ��+`? a7�\RQ!�����nR�N����L��8��H��� CS��1ǀ�C3N��,PW���w�=�,��>����]Y�2Ê#�L�,�c�vX���Ԕ�ܱ��'j���]Y̩��r@���CW5p +��A/m,� ����x�N��X̩o������ѷ!���,�n/AK:�[�X��Kҡ�Ò���q��%�8�%����ŀ��5v��3�B�Z���-�n��U�K҇�p1��/I���`{��"�KҖk)
:��%�8�<��m�����ixe}�������+���_b��^| �Һ�� �O���U����O�@�Z���,f����ǆNa �Y��O��6i3��>�t�.�b���z��,� l��`AK��'T1X��&\ӐX�! e�2X��t\�~ݚ���¿< �Yg�m6��KҒ���t��aq��|\U��\��x��D�%h��xY��/9#�&���o0_r֙^�����'�Y�0|Cl����r;Х���>YΊG
�1,>�'��p�c����,f�@���ˍ?�Y��%á���rVbq2�F� ��0�b3l+���bAk:iXI�(��y2��nu6K*_v G����\�|�de�^��Z鲼�_8�*�}�J��d�L=6^�v�(��)D�J�}q���}���.; ;Qˡ�H�.; ��0��|�|��7�!X���}̰r~
���a��h�j��[a��=Ty� ��|cM��?	��h���̠�it�P�q�6&*�v I��&� �F�1�|T� <��%tK�� ɒ0��I�J�	B&y.}f�br@��h��^虽�KK�� _Z-,~��&T��&]"�G;��P�P
7H�� q�8��&�K*�v vl�PW�YY�줭O�X��X���2_��<�L�nCz�KW� V2��V�<��4q0Uu%�GK�Gp[#:F*���=���*-&`�x�x����Xp�sdLl�����x]�iN�TVLn�����@ f�N�z��/ԣU�;���ҡƜB ¬�	uX8�G�0+v 6?+���_`�e�(6��rR�¬؍,��	9~闠ñ��8��i/L!~ВKos[/L�8�w�`Ig���07{��������,a��e�@6��&L���g�-KAJa���e��r���؉8�Z'�����[X�(?a, ����N��0�%I*���w�_�>�l��'(�_ (|�8�E��/ ҭ��F,�0�%IsK�'�w�$fx�@2�@b���7��U�� Ȥ[��
�_ dDxu� ��XIs�!��Ă�|iEg_
�_�����Y�1�%�)�W���f�$~qBI��*�~�|� �3���K0L��/ If���MŴ�G��~,~f�p}����CL����ж��a�0-�8br�t��	�b d࿁�a��@������´�ę.��zfZ, �"��f��aZ�s ���BaZL�۽��y�3-&�v�ІᲰ~fZL�)Fv�\F>�0-v af����K´��m᦭��dZLҍ�ŵ֠��0-&�+lk�x�0+&��&����W���f�Pp�����b�z���m/�J��t�%6��(�;���' 3�Ri�/ �&�s��b���-i�6H����!aC8�T*/��P*������b���&���ʋ%@RMNDq�V^� 2�?���ҫ����	�e�ʋ% .Q���ֱΨ���s�H���; �q>��c�K��dC���(+1v ���q�Q��Tb� 2Sm�SG*��b��Cw��+-�7ԭ���d��b	���%�`7^r��W,d�ߨ�b	��(�p� *�u ���S�?j��`fB��Ͷ~�� �5B�0�%���o7�j�G�u���q�#
'��
���(�eE�%�tO.}g�&�>Z�/�1�ԄKZ�/�1а�i���_`0��#m2Ƶ�_��s;_g K�߼jե�j�`A��AG�V�� �����:"��W�؟��mZ����
Q8����: ��g��"���J�Gc�F+�u �M�Yw��K:��}����f&6����Xҧz"���b� ��$C �6.�V�� ��_c,ҭZ	�t�买��8�J���3�Q�Q+c�#W�*�ʘ��
�aҡ��1�]F��V�Z�H�N�F֒V�LodUF�+)�U+c�72��'B_�fz�HTk�WR���z;�H�Z���F1���e}[��H/9C�aG��(�ʗ�J�&�Zh��`g�6
h�V�,�R-Nٔ���/;����r�V��0��i����0S��@���%��,���=��J���%Sp�$�U+av�Oko��(�P+av �Dj�d�i%� ?j��jh%�`'	��@r�~�o�`��~���ddVB���0;��ia*�E��0;�d��^����0K����ua˧�e�z�#��m+�|�HF�Î"�A+_v �Iu#�P	�/ ���n�U+a� $�A빲mU�1�Ƅ�'#�ke��Ƅ��ޖP0R+5� �2�P��k�Rc��+�`_+5�7���|9�Z�1��b&��a��Z��d����O��; ;�<�R��R���N��Rc`8qۜ����K@,��Չ2�J�@zd�Z�#�Rcz+�m �e�Y+5� ��aȄ��Fq����'�D\&��*5v ��L�=*��J�}��Gɀ��}��ˀ�ە�1 �@�h�fr� �{䪼�C�хx����Kze�ACŲR��    29��D����7�c l��0g�Q&� i]��8_�%�Ҡ\`��r��1 �n��_`I��P�˙C�caX3'�@� �'[���-15�f�Y�G;��1 b� L=�)Sc'`�#q9Gx�Rc��^�QL��I���&T��l_�Ԙ}3e{��!�������6��Ś��c��f��>�ܘ}S4w��)�O+7f�Tg�tc-V�1��
�D6�rc�Y�wJ/�ʍ%�P:���p�Vn� 2�Б�����=�9�x	�3�Ц��^������K�H&�p��0�Un���h������*7v ���~�V�Un� ����)D�Z���z?h���%�Y7㐎C�~V�����I#"�*7� E�=6-o������J��X���&+8NϱJ��M(FR�1�c��ozpf������eV��X���~nD��B��k����[9B-�Ѻ��t~�)_���"X��{��M����$�,?��GP`�1~oD�gD=����NǛU�m#A��K��ds[%��u�ϩ��*�CD�;��Z�*�v ��	#��N����#O��t�X��6jPOYyo�lU���L��a�o:{��n_@8�a�sډU�� 2q��c�w; T�,v.�o���v؆�V��X�LYT`�x;�'i���;��{�p��5f�o�3�b�w��[�e��8��Z�J��aq�c�Wy��ޏ�>g<Y�� 3�6ڞ�w;����@:^r��O��{In�w�0&3��xaT�� ��?1��A}d��M��ʼ�o˱��{نV���M�B��ш_�ʼ�"�^����2o��Ϛ=�cXe���%AG4�2o;�v��LK��K:��0��M��ʼ% �XX�I2�%����˯��NCpx�� ���b��֔�\�����n!���o0S)M�eV�������~��[��g�A�a���)�� �;Nh��\+��X&B�<�[!�.@��L�73�B�]@2�=�%Y!�. �_�BqV+����k6�	�B�]���>���
�v �9�{�����F�MaS/I�B��"XL_i���c`i�3� ����چ�-�:f��{�z�R�:�z=�9��a"h�H �3�(3=�2e�XΚ��~b�J�Ir�Sg���B�$g r�,�� 9�܆��	��6I�')U�8ѹ��M��d�Q3���Ib>I��I8�-�M�3rF�i�1���I���W�󐟈�,飃���I2I�'�5l��qж^bFaE�q
��z�ٳ�\�Q�����;�#޹���K�0��ٴ:%��b1��Z�H��,��r�kY�1#Ym����n����m�����#��bAg�kx�c��h�%�7�����7K:���,#B�
���7)�^�n�v�r��ؔa�v�pd�NZ��. =�>h,B�.+��  �l�i,�B�]@&D/φ�0_�S�0�3��n�d�#Ӑ?�~����'2^h�.�v�~��[�x��.�Nwѱi�zcI�i�ncsL�K:Mb����"W�X���e�k4��ycI�R*��M~�t�5ة���%�y�BU���GbI' |Jԃ���%}2!�n}����%��;�QN������hJ[�����P4}���$��/��l�xI��P�69���K�h��թ���KҒ]g:(��/A�!���A�������"�8��%h�3�������ug���4��m�hc5]��\^����U:9�./A�|.�NԻ�K����X�·��K�0��rp�����d.�#!�KҞek���PyIڳ�Z( ��\^��Ln�!�ZI_������G.��K���F�X3j;����~k�w��_rF!��D����ČV��X̖�O&:��W��q5�R3��+�ٲ��fX��b�Ō����� ��� �>�:��n,g�e�s�gA��r��}�$-�
`9[�Es�޺n,h�$4g�
xI�f�F�xm~����|���[�!s{I�{!��m$鞏�$�EY�H�=�z[�@�`!�/6�U'A��4��zt�r'A� _CQh� ��/<J��c��t���Y�;���>;k�J�%�4���J�w��������K��l9f$��Ax%� s��y��Wb����KWb� Rh�i ���T����c�t��g�� �+1v 3�(|;[J�;����+�J�%��{aN>�Reƾ��~:W�{�� ���;�;��y���]R��H��2^���r�p��j^�������2c����6$�ʌe�,�A���c��t��5��YΨ��j�X�}*3v h��J-bX�cy}?�f�I�$fIz?,�9"{���B��%�x�� ���.n|�����	Ç��^���5i[�ʌ}��'��f5Y��X���qu��XN.�Bw~g�3 �Z����-IևNB�!+�ʌI�[��(2�; �)!�FSJ�Wf� � a6n������Vl�3+&'fg�s�b�7xl��3P*���,�ll�)�L�I�]:��p��3)@f(!���Τ�d٥���+e9�b�]yCפI�Τ ��!�q�`R�dM���m��b'mB�6�3�5�;i֭8��&�$ ���&� ���Qe2���t��C�L�I��Ϋ���L�I�-�w���/�$�Y��g��+�%铒�qu)�Ĥ�xCX�� ���L�r��5�;A4��C٢�91�V�!������	���0sp�����	�`.�d��
`A�L�x�z�V7�b7k�Q�0'��b0	G�� �9I�i3�˜sb`�iq|�eN�S�,]�)��$�X�̫p;������4�$����$+�4{���sb O)L��K��sb�����̉Aq��K�=5"�sb��!���`�J/IK�]nn�0�C.J˺kٍ�l�� ��e|3�9�;�c� ��m�� pX�H��̜ #�����9��Och_���+�%�O3\8�<�;��g\�>��$1I)��_(b>�K4'���9A�rb_ �Y��rb�n*a�.!�ڮ��ޜ�X�:�:���@	���c�rb��qWC=м�Q9�д�P�Ck�rb�>Y��\X3*'v �c3�=*'�7��OQ��rbz�Qµ[����;�"���̍�PI������%�#y��H/]Y1�N�@
��W����	���G����~'D�}��U+)�w.fX���|�:�����rb;�8:����Ѡq���Y9��3�a;��ʉ�%B��1'���rb�mA���+�ʉ��솺џ�]91��;^h[):*'�팀���!  :� P�М�jG���&)�]�4#6fTNLo�ʕ0��_�%}ЉڽM�Ҩ���*�dI̉�ӛ '}e9G��OB@؟���=*'� �`���/^{�;���&IuWRL�Kf��:��PI�@3�''���K����QY�h�$��cG%����!���4aiTR� ���sBĨ��޲t����bz�R�4��
 A_�n���5VY1M��.��0�++����+�Q�Ũ��^J�ǭq�QY1�R2H�j<�rTVL���g	2����bz�L@6�E?*)���H��ۉ�J��e?�`/>�*/f7�:N��Z �O;� ������>nt,�Gk�J��ml��S��*af7�7����T����y�2O�gZ��0��H��SC�Q	3�r�i�T��G%��r᥽z��ʗ�M�6Wf���rH�T���a`�M�B�Y��Ic�a]ó�ev�w�bGk�*�Y�2��ux��ZA%7��ev�k��ܗ|V�,8�Vm��ʗ���3}vp�׬|�]����@Hҕ0K��%�v�����[^ff�7+af��,����� /I[J���j�Y	3��:$�353��/�o�Xt�1�!��/��.��7Z��f�����E�|5�!g%������R�쬄�}z�/�����߄^��a^#��f~�W��P��b���_9'`�i�T�� rdNإ\�0+a��h�2�񆫄��֝`	����Y	3��K��8�aV���i�9���8+a�n(���E�    ﬄ�ߺ!��A�nZ��2�K[�Pި��G����B#��
:�ʙ�.��>�|`�ʙ���-�G0+g�߶��YH���T93�m/1~Ỉd��3��@G!-��f������}B�/��g�������}%x�V�̿],��ƣE����ߦ� ��O$�eV�̿C���H�rf����s�Ƭ���.��,�
9+g�ߦ�8��	f���6��H�4�c�rf~�R"�!��ʒ���Y�Ww���z��U�`g�� ?����'���dT�9^�Rf~g*"�
��J�}�Z�4��2��Z&l	_�wh����Tę���\�Y93�#1�W&�	��3��!u;���_r����x4>N*gv ]���:zV�� 2�Jdso�Y93��;����H�3�K�����g���6��� �DA�Y)3��n�2��f��J�}8��?�>R�� �7Q�0�*e��6�}�&E�g��<�#I�=�ʘ�-��Asn�=+c�}�_�a>ŵge�����`x�ߟ��$p��������,t�4�բ��Oh`����������ݶ�֫�_g��nNYϳRl��	��{��J���-5�If����ң�Mg�mV��o�/���R��_o)��q�`V�ͯ��!�FOT�XY���fe���
;�� 9���y*��a�[�5�c	P�<��q��Fk�l��s��3�5+�6��m�Iq�l��}�Ru�`�۸ơ5�<�D��J��kzlõ(}aV�m\���I�<�Y�q[��\��8+�6�i�ǹP�vV&m\cҳ5=w��I��ٞ���LڸӰ1�b�A���Lڸӭ�p��K�d�L�H�-��0�xmW"m��0bbi��Dڸ�*.�䧯ʤ@�U��\�2i�Z�0�C��Q�*�6��
�;6%a�ʤ�k}6E��;��ʤ�t��9��lU&mܮ�(4��ӰWe��ml�@^�\��*�6n�uL�24Z#�K����F�xI�L�@Qr�Ve��Ѝ
Q���KW&m�6���HҕI�^Eo����*�6n6\��V��ʤ�oסP�ބ��V����"��(�U��q�ŖΞ��r������=oW����B�W�����f�QU@���v�VN�"��*�6n�����KvҪ<ڸ�B����zxU-��lݽc]<���|���׃�\�F; ԫ���ƛ��h�R����-�We��epsБrb۪,ڸF	�<�#�*�� �Ad�Y�E�$FH�(�+�6�=�|��� /9{����9���h��ۜGY�ʢ�KC���Ɗ��h��)̷e�*��`�j�׬�+�6�D7�B�� /I��Ȅ�ɇU%��%Ƒ!�ђ�
�D��sg�6���8\�D�w�WN�s%OiUm�1^jg������H���*�6/mN������h��XJ�_/=����f`M�*�v i��;I��UI��ޒil�ht�*�6�쥜k�hֱ*�6/�����D���N#�s�UI�ym�_+���*�6�)R+��ԫ�h�<��	�XV%���Pe��J��h��n�|�͉QZ�E��;#u�2��h��nY��J��h�_��T!�gUm�ZI$%��sUm~� �=&?V����n�B�$}��0lY�aV� ��>�[L�J�%��X�0�ٗY�F;�}f/9�MW���-Ci8�\��h`����ʣ�ib�C���h�Fɒ���䪩g�;��q�Ъ�ؼ�QP� ND���ؼ�Q����Si���s�n��KVW�� �%��įJ�%�p�}��"���b�]�rn�*/6��T���J�wx	:t�"u�
���d���
+�%h˹_�}�J�ͬM�"q�]�A+1v ����H$i�L���Ȭ�
 I�����f� $�S.�i���T��GĖc I�v� R���I��E�8�~Ujlފ,t�c��c�Rc��+�d&k�J����:2oG�S']\������s�s�;�84L���S��c�k�����y[s7>e*av��B��0�+a�n
����2f럜A����~ ��õ��JaW�l}�"A��#ߕ1[w�+�LC�th�ʘ�;�ٍ�hְ+cv F"��۱�ʘ��������&�+c���&9wcS�rW�lݑ�([R��]�u;��	�z�"�ʘ��Yw�� �$��ɱ�]�u[���]���ە1[7S3Q���]��m��DIc�rW�� ��}'Hk�2f�����ve��J۠@����+c���5�q99�rf��qT"���Ʈ�ٺ�����шٕ4K��$�du�J��uΐ�,~�J��DFC�����+i�����U���f�=×3=�ח $��r0\ד�{F/��tq�Ӯ�YN1؜2�NcW�� v6HJ�� $hx���+��2�ʚ%�g��F��QY��Ƥ��r��Y��㠤�Ȯ���B����˔��ʚ@�F�7񯻲f+������Ce��?E等R֮��JV;]憀')�ʚ�/K��71���ʚ�۫��M��v�� iu�1�jNw�������C'�bW�l}��0.ޕ5[ߒ�XJ͍����f��[Aؒ�*iv��&4`�L��f떐#gN]�b���� s��4��3м+i�n� �Č�J��+@�{�#�Gٕ4[�X�α/|�W�� ���.�|�V�l}�h�3��Uw%��M(w�c_��pW�l'���]Js�J�4; ������8��f	�r�Bqk�]9�s=���RX��A� ;o=��~rrf��o�+e��ǂޖS'�J��\�ũջRf_ z%��I�?+ev Y7�q�P~���پ��rn��F��Rf��̄���w��p��f�����J��kף���H�Y����m?$](3�n!���=w��D/��E�\9�e�`�)�P��d4�Y���FB7:�
-{�Q�{.� Na�FOJ~T{2�}�VڅK�o�1x�eL��¥�w{C�R�0߀�ٱ�}�¥]@�s؞Z���HE&��t�����n/^y5�,;w���xe�e��'�z-�xVUP��kXV����x���O1�����^����nNd�^/�;>̞ɻg���x,V�y��^$��R�������"�_�0�å\��7�YNL�q���Mb�j����{���'p��x���$�3�)��RΫܛ�,�4�1g1�Mr��	�eG�7�Y�y՘�B}{���S ����'�K�蹍ws���/9[3�ut%w����O[�x$j����-�Ʌ�z-�	�K����3K�n�KоN��� ��O�� ��� ���m�L#���K:��@��+����QxomU�'�����MJiX�K���)�n��Β��U$=��_�ni�%�����0uT�7 ,�컏y ��ǏĒ��M9�Iv��j�$g>��+�d� ���鰗�_��3�͖ʖ�@~����	Ճ�ҩ�m�L? �~@ˮ��W����z�>aBS��= wLv��j��u�d����G\���p� ,�£� \�:M~�� ��AzNe�������p��ā�j�7� �z�NM�	�9�z�n`7jk!MY�ي1[%�a,�p���ƨ\` X����D�`=�,��mUrB����s��CM��4�P̉�hOI?�:�}�C���� ~���N
���p:�6a2+ ������,Z�;ȿ����}D+�$[���v���h�܉���++�h 0p[X����V  +O5�ߤ����~����<��T�f� �4 �2���,6�4 �<Xm�~3��ɶp��4
�� yv1cF�_��,h]F� ��K��;@��FeN`A�`���bU&U���g�s�8�6jG���1B��4n���F�3@�^}�p�@^?��qV�@_���¸WlP����9da��ި,�su��`��+2~򜒈��<��}���͓r����j]D�taL�ύ=ѹY!�2���NZ�6F.��_؉Q� ���?ܞ�o�]eZG����,���ѩr]�����-<Pa����; O#��f����x��`(��n�_ �K��D��p{�m���Ȑ���D~�� Xfz��Q��`^f6?EyR�� �� Q  _�3��ŉP$����w�/�����T� i�ĩ�8��� �`]N�/@�_?��| N��y�Ws� /61 ���� C��a� #�4,���Hzܞaq��#@}� /�e�Z�ļ�� i�q^/b5�f�t�+R������~{�k� �㎵��� ĎTLLLY��ӼQ$�퍙�?7*+`~=5�kQ[��T ����B�9�	I�e���d�;��N�����9�Ƶ @z�B��m}r��Fծ?�Ӗ-��c������d�d�`&@����+fiyx�S$���}~�I�!�P�?7Zt��iX9��w�M�m8����~�,=��s'��Zk~���H]g=����ȸ��4�9�W���_A�V�_S������~x�s#{ܨ�P�8[7�ޜ ��v�^Z��E�;�Q?7�-�2:�ԩ��@�Ӥ�]�����c@ŁA�ro����B�)z�����x���u��&�LA���';���Z���z�;'[¿�ӳw^0Yz�N�ƣ1�� �is����+�S2�T2�� ��� �W���	d�>+���D;f�J�������?��     