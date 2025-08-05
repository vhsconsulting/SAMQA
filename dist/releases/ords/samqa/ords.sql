
--

DECLARE
  l_roles     OWA.VC_ARR;
  l_modules   OWA.VC_ARR;
  l_patterns  OWA.VC_ARR;

BEGIN
  ORDS.ENABLE_SCHEMA(
      p_enabled             => TRUE,
      p_schema              => 'SAMQA',
      p_url_mapping_type    => 'BASE_PATH',
      p_url_mapping_pattern => 'samqa',
      p_auto_rest_auth      => FALSE);
    
  ORDS.DEFINE_MODULE(
      p_module_name    => 'External Ticketing System',
      p_base_path      => '/sterling-ticket-system/',
      p_items_per_page => 250,
      p_status         => 'PUBLISHED',
      p_comments       => NULL);

  ORDS.DEFINE_TEMPLATE(
      p_module_name    => 'External Ticketing System',
      p_pattern        => 'Get_Ext_incident_Comments',
      p_priority       => 0,
      p_etag_type      => 'HASH',
      p_etag_query     => NULL,
      p_comments       => NULL);

  ORDS.DEFINE_HANDLER(
      p_module_name    => 'External Ticketing System',
      p_pattern        => 'Get_Ext_incident_Comments',
      p_method         => 'GET',
      p_source_type    => 'json/query',
      p_mimes_allowed  => '',
      p_comments       => NULL,
      p_source         => 
'select * from table(pc_incident_notifications.Get_Ext_Api_incident_Comments(:incident_Id))');

  ORDS.DEFINE_PARAMETER(
      p_module_name        => 'External Ticketing System',
      p_pattern            => 'Get_Ext_incident_Comments',
      p_method             => 'GET',
      p_name               => 'incident_Id',
      p_bind_variable_name => 'incident_Id',
      p_source_type        => 'HEADER',
      p_param_type         => 'STRING',
      p_access_method      => 'IN',
      p_comments           => NULL);

  ORDS.DEFINE_MODULE(
      p_module_name    => 'oracle.example.hr',
      p_base_path      => '/hr/',
      p_items_per_page => 25,
      p_status         => 'PUBLISHED',
      p_comments       => NULL);

  ORDS.DEFINE_TEMPLATE(
      p_module_name    => 'oracle.example.hr',
      p_pattern        => 'empsec/:empname',
      p_priority       => 0,
      p_etag_type      => 'HASH',
      p_etag_query     => NULL,
      p_comments       => NULL);

  ORDS.DEFINE_HANDLER(
      p_module_name    => 'oracle.example.hr',
      p_pattern        => 'empsec/:empname',
      p_method         => 'GET',
      p_source_type    => 'json/query',
      p_items_per_page => 25,
      p_mimes_allowed  => '',
      p_comments       => NULL,
      p_source         => 
'select empno, ename, deptno, job from emp 
	where ((select job from emp where ename = :empname) IN (''PRESIDENT'', ''MANAGER'')) 
    OR  
    (deptno = (select deptno from emp where ename = :empname)) 
order by deptno, ename
');

  ORDS.DEFINE_TEMPLATE(
      p_module_name    => 'oracle.example.hr',
      p_pattern        => 'empsecformat/:empname',
      p_priority       => 0,
      p_etag_type      => 'HASH',
      p_etag_query     => NULL,
      p_comments       => NULL);

  ORDS.DEFINE_HANDLER(
      p_module_name    => 'oracle.example.hr',
      p_pattern        => 'empsecformat/:empname',
      p_method         => 'GET',
      p_source_type    => 'plsql/block',
      p_items_per_page => 25,
      p_mimes_allowed  => '',
      p_comments       => NULL,
      p_source         => 
'DECLARE
  prevdeptno     number;
  total_rows     number;
  deptloc        varchar2(20);
  deptname       varchar2(20);
  
  CURSOR         getemps is select * from emp 
                             start with ename = :empname
                           connect by prior empno = mgr
                             order siblings by deptno, ename;
BEGIN
  sys.htp.htmlopen;
  sys.htp.headopen;
  sys.htp.title(''Hierarchical Department Report for Employee ''||apex_escape.html(:empname));
  sys.htp.headclose;
  sys.htp.bodyopen;
 
  for l_employee in getemps 
  loop
      if l_employee.deptno != prevdeptno or prevdeptno is null then
          select dname, loc 
            into deptname, deptloc 
            from dept 
           where deptno = l_employee.deptno;
           
          if prevdeptno is not null then
              sys.htp.print(''</ul>'');
          end if;

          sys.htp.print(''Department '' || apex_escape.html(deptname) || '' located in '' || apex_escape.html(deptloc) || ''<p/>'');
          sys.htp.print(''<ul>'');
      end if;

      sys.htp.print(''<li>'' || apex_escape.html(l_employee.ename) || '', ''  || apex_escape.html(l_employee.empno) || '', '' || 
                        apex_escape.html(l_employee.job) || '', '' || apex_escape.html(l_employee.sal) || ''</li>'');

      prevdeptno := l_employee.deptno;
      total_rows := getemps%ROWCOUNT;
      
  end loop;

  if total_rows > 0 then
      sys.htp.print(''</ul>'');
  end if;

  sys.htp.bodyclose;
  sys.htp.htmlclose;
END;');

  ORDS.DEFINE_TEMPLATE(
      p_module_name    => 'oracle.example.hr',
      p_pattern        => 'employees/',
      p_priority       => 0,
      p_etag_type      => 'HASH',
      p_etag_query     => NULL,
      p_comments       => NULL);

  ORDS.DEFINE_HANDLER(
      p_module_name    => 'oracle.example.hr',
      p_pattern        => 'employees/',
      p_method         => 'GET',
      p_source_type    => 'json/query',
      p_items_per_page => 7,
      p_mimes_allowed  => '',
      p_comments       => NULL,
      p_source         => 
'select empno "$uri", rn, empno, ename, job, hiredate, mgr, sal, comm, deptno
  from (
       select emp.*
            , row_number() over (order by empno) rn
         from emp
       ) tmp');

  ORDS.DEFINE_TEMPLATE(
      p_module_name    => 'oracle.example.hr',
      p_pattern        => 'version/',
      p_priority       => 0,
      p_etag_type      => 'HASH',
      p_etag_query     => NULL,
      p_comments       => NULL);

  ORDS.DEFINE_HANDLER(
      p_module_name    => 'oracle.example.hr',
      p_pattern        => 'version/',
      p_method         => 'GET',
      p_source_type    => 'plsql/block',
      p_items_per_page => 25,
      p_mimes_allowed  => '',
      p_comments       => NULL,
      p_source         => 
'begin 
 sys.htp.p(''{"version": "19.2"}'');
end;');

  ORDS.DEFINE_TEMPLATE(
      p_module_name    => 'oracle.example.hr',
      p_pattern        => 'employees/:id',
      p_priority       => 0,
      p_etag_type      => 'HASH',
      p_etag_query     => NULL,
      p_comments       => NULL);

  ORDS.DEFINE_HANDLER(
      p_module_name    => 'oracle.example.hr',
      p_pattern        => 'employees/:id',
      p_method         => 'GET',
      p_source_type    => 'json/query;type=single',
      p_items_per_page => 25,
      p_mimes_allowed  => '',
      p_comments       => NULL,
      p_source         => 
'select * from emp 
where empno = :id');

  ORDS.DEFINE_HANDLER(
      p_module_name    => 'oracle.example.hr',
      p_pattern        => 'employees/:id',
      p_method         => 'PUT',
      p_source_type    => 'plsql/block',
      p_items_per_page => 25,
      p_mimes_allowed  => '',
      p_comments       => NULL,
      p_source         => 
'begin
    update emp set ename = :ename, job = :job, hiredate = :hiredate, mgr = :mgr, sal = :sal, comm = :comm, deptno = :deptno
    where empno = :id;
    :status := 200;
    :location := :id;
exception
    when others then
        :status := 400;
end;');

  ORDS.DEFINE_PARAMETER(
      p_module_name        => 'oracle.example.hr',
      p_pattern            => 'employees/:id',
      p_method             => 'PUT',
      p_name               => 'X-APEX-FORWARD',
      p_bind_variable_name => 'location',
      p_source_type        => 'HEADER',
      p_param_type         => 'STRING',
      p_access_method      => 'OUT',
      p_comments           => NULL);

  ORDS.DEFINE_PARAMETER(
      p_module_name        => 'oracle.example.hr',
      p_pattern            => 'employees/:id',
      p_method             => 'PUT',
      p_name               => 'ID',
      p_bind_variable_name => 'id',
      p_source_type        => 'HEADER',
      p_param_type         => 'STRING',
      p_access_method      => 'IN',
      p_comments           => NULL);

  ORDS.DEFINE_PARAMETER(
      p_module_name        => 'oracle.example.hr',
      p_pattern            => 'employees/:id',
      p_method             => 'PUT',
      p_name               => 'X-APEX-STATUS-CODE',
      p_bind_variable_name => 'status',
      p_source_type        => 'HEADER',
      p_param_type         => 'INT',
      p_access_method      => 'OUT',
      p_comments           => NULL);

  ORDS.DEFINE_TEMPLATE(
      p_module_name    => 'oracle.example.hr',
      p_pattern        => 'empinfo/',
      p_priority       => 0,
      p_etag_type      => 'HASH',
      p_etag_query     => NULL,
      p_comments       => NULL);

  ORDS.DEFINE_HANDLER(
      p_module_name    => 'oracle.example.hr',
      p_pattern        => 'empinfo/',
      p_method         => 'GET',
      p_source_type    => 'csv/query',
      p_items_per_page => 25,
      p_mimes_allowed  => '',
      p_comments       => NULL,
      p_source         => 
'select * from emp');

  ORDS.DEFINE_TEMPLATE(
      p_module_name    => 'oracle.example.hr',
      p_pattern        => 'employeesfeed/',
      p_priority       => 0,
      p_etag_type      => 'HASH',
      p_etag_query     => NULL,
      p_comments       => NULL);

  ORDS.DEFINE_HANDLER(
      p_module_name    => 'oracle.example.hr',
      p_pattern        => 'employeesfeed/',
      p_method         => 'GET',
      p_source_type    => 'json/query;type=feed',
      p_items_per_page => 25,
      p_mimes_allowed  => '',
      p_comments       => NULL,
      p_source         => 
'select empno, ename from emp order by deptno, ename');

  ORDS.DEFINE_TEMPLATE(
      p_module_name    => 'oracle.example.hr',
      p_pattern        => 'employeesfeed/:id',
      p_priority       => 0,
      p_etag_type      => 'HASH',
      p_etag_query     => NULL,
      p_comments       => NULL);

  ORDS.DEFINE_HANDLER(
      p_module_name    => 'oracle.example.hr',
      p_pattern        => 'employeesfeed/:id',
      p_method         => 'GET',
      p_source_type    => 'csv/query',
      p_items_per_page => 25,
      p_mimes_allowed  => '',
      p_comments       => NULL,
      p_source         => 
'select * from emp where empno = :id');

    
  ORDS.CREATE_ROLE(p_role_name => 'oracle.dbtools.role.autorest.SAMQA');
    
  l_roles(1) := 'oracle.dbtools.autorest.any.schema';
  l_roles(2) := 'oracle.dbtools.role.autorest.SAMQA';

  ORDS.DEFINE_PRIVILEGE(
      p_privilege_name => 'oracle.dbtools.autorest.privilege.SAMQA',
      p_roles          => l_roles,
      p_patterns       => l_patterns,
      p_modules        => l_modules,
      p_label          => '',
      p_description    => '',
      p_comments       => NULL); 

  l_roles.DELETE;
  l_modules.DELETE;
  l_patterns.DELETE;
    
  l_roles(1) := 'SODA Developer';
  l_patterns(1) := '/soda/*';

  ORDS.DEFINE_PRIVILEGE(
      p_privilege_name => 'oracle.soda.privilege.developer',
      p_roles          => l_roles,
      p_patterns       => l_patterns,
      p_modules        => l_modules,
      p_label          => '',
      p_description    => '',
      p_comments       => NULL); 

  l_roles.DELETE;
  l_modules.DELETE;
  l_patterns.DELETE;
          
COMMIT;

END;


-- sqlcl_snapshot {"hash":"31639f26c1485b3278e4bff608af30be207341d0","type":"ORDS_SCHEMA","name":"ords","schemaName":"SAMQA","sxml":""}