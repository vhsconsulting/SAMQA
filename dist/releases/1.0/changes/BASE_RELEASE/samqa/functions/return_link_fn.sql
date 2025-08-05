-- liquibase formatted sql
-- changeset SAMQA:1754373928301 stripComments:false logicalFilePath:BASE_RELEASE\samqa\functions\return_link_fn.sql runAlways:false runOnChange:false replaceIfExists:true failOnError:true
-- sqlcl_snapshot src/database/samqa/functions/return_link_fn.sql:null:9f7d8b98d5686d610783fd2ff81569c15b983a33:create

create or replace function samqa.return_link_fn (
    p_page          in varchar2,

   -- page to pass value to

    p_item          in varchar2,

   -- item to pass values to
   -- comma separated list of items (P1_ITEM, P2_ITEM)

    p_value         in varchar2,

   -- concatenated list of values (empno||','||deptno)

    p_image         in varchar2 default 'Y',
    p_image_n       in varchar2 default 'view.gif',

   -- if p_image is 'N', column value or any string can be used

    p_hidden_tab    in varchar2 default 'N',
    p_sort_on_link  in varchar2 default null,

   -- if the generated link needs to be sorted, the hidden tag
   -- will be created and put in front of the link

    p_popup         in varchar2 default 'Y',
    p_width         in varchar2 default '700',
    p_height        in varchar2 default '700',

   -- the link window is popUp2 by default

    p_request       in varchar2 default null,
    p_reset_p       in varchar2 default null,

   -- passing a request or reseting the pagination is done here
   -- (p_request 'DELETE_ID', p_reset_p 'RP;300')

    p_prepare_url   in varchar2 default 'N',
    p_url_charset   in varchar2 default null,
    p_checksum_type in varchar2 default null,

   -- these parameters are used for apex function
   -- apex_util.prepare_url
   -- for lower versions of ApEx
   -- use htmldb_util.prepare_url

    p_session       in varchar2 default v('SESSION'),
    p_app           in varchar2 default v('APP_ID')

   -- these parameters are default

)

/* This function will return a link in an SQL query. */
/* SELECT return_link_fn (500, 'P500_DEPTNO', deptno,
          'N', 'My Link') LINK,
          ename, job, hiredate
  FROM emp */

/* SELECT return_link_fn (500, 'P500_DEPTNO', deptno) LINK,
          ename, job, hiredate
     FROM emp */

-------------------------------------------------------------------

 return varchar2
    deterministic
is

    v_link    varchar2(400);
    v_sort_on varchar2(400) default null;
    v_exception1 exception;
    v_exception2 exception;
    v_exception3 exception;
    v_exception4 exception;
begin
    if p_popup not in ( 'Y', 'N' ) then
        raise v_exception1;
    end if;
    if p_image not in ( 'Y', 'N' ) then
        raise v_exception2;
    end if;
    if p_hidden_tab not in ( 'Y', 'N' ) then
        raise v_exception3;
    end if;
    if p_prepare_url not in ( 'Y', 'N' ) then
        raise v_exception4;
    end if;
    if
        p_hidden_tab = 'Y'
        and p_sort_on_link is null
    then
        v_sort_on := '<INPUT TYPE="HIDDEN" VALUE="'
                     || p_value
                     || '" />';
    elsif
        p_hidden_tab = 'Y'
        and p_sort_on_link is not null
    then
        v_sort_on := '<INPUT TYPE="HIDDEN" VALUE="'
                     || p_sort_on_link
                     || '" />';
    end if;

    if p_popup = 'N' then
        if p_prepare_url = 'Y' then
            v_link := apex_util.prepare_url('f?p='
                                            || p_app
                                            || ':'
                                            || p_page
                                            || ':'
                                            || p_session
                                            || ':'
                                            || p_request
                                            || ':NO:'
                                            || p_reset_p
                                            || ':'
                                            || p_item
                                            || ':'
                                            || p_value, p_url_charset, p_checksum_type);
        else
            v_link := 'f?p='
                      || p_app
                      || ':'
                      || p_page
                      || ':'
                      || p_session
                      || ':'
                      || p_request
                      || ':NO:'
                      || p_reset_p
                      || ':'
                      || p_item
                      || ':'
                      || p_value;
        end if;

        v_link := v_sort_on
                  || '<a href="'
                  || v_link;
        v_link := v_link
                  || '">'
                  ||
            case
                when p_image = 'Y' then
                    '<img src="/i/'
                    || p_image_n
                    || '">'
                else p_image_n
            end
                  || '</a>';

    else
        if p_prepare_url = 'Y' then
            v_link := apex_util.prepare_url('f?p='
                                            || p_app
                                            || ':'
                                            || p_page
                                            || ':'
                                            || p_session
                                            || ':'
                                            || p_request
                                            || ':NO:'
                                            || p_reset_p
                                            || ':'
                                            || p_item
                                            || ':'
                                            || p_value
                                            || '''', p_url_charset, p_checksum_type);
        else
            v_link := 'f?p='
                      || p_app
                      || ':'
                      || p_page
                      || ':'
                      || p_session
                      || ':'
                      || p_request
                      || ':NO:'
                      || p_reset_p
                      || ':'
                      || p_item
                      || ':'
                      || p_value
                      || '''';
        end if;

        v_link := v_sort_on
                  || '<a href="javascript:popUp2('''
                  || v_link;
        v_link := v_link
                  || ', '
                  || p_width
                  || ','
                  || p_height
                  || ');">'
                  ||
            case
                when p_image = 'Y' then
                    '<img src="/i/'
                    || p_image_n
                    || '">'
                else p_image_n
            end
                  || '</a>';

    end if;

    return v_link;
exception
    when v_exception1 then
        raise_application_error(-20001, '</br>'
                                        || 'p_popup parameter has to be either ''Y'' or ''N'''
                                        || '</br>');
    when v_exception2 then
        raise_application_error(-20001, '</br>'
                                        || 'p_image parameter has to be either ''Y'' or ''N'''
                                        || '</br>');
    when v_exception3 then
        raise_application_error(-20001, '</br>'
                                        || 'p_hidden_tab parameter has to be either ''Y'' or ''N'''
                                        || '</br>');
    when v_exception4 then
        raise_application_error(-20001, '</br>'
                                        || 'p_prepare_url parameter has to be either ''Y'' or ''N'''
                                        || '</br>');
    when others then
        raise_application_error(-20001, '</br>'
                                        || 'Invalid parameter!'
                                        || '</br>');
end return_link_fn;
/

