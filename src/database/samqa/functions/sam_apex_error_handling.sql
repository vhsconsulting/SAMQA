create or replace function samqa.sam_apex_error_handling (
    p_error in apex_error.t_error
) return apex_error.t_error_result is
    l_result          apex_error.t_error_result;
    l_reference_id    number;
    l_constraint_name varchar2(255);
begin
    l_result := apex_error.init_error_result(p_error => p_error);

    -- If it's an internal error raised by APEX, like an invalid statement or
    -- code which can't be executed, the error text might contain security sensitive
    -- information. To avoid this security problem we can rewrite the error to
    -- a generic error message and log the original error message for further
    -- investigation by the help desk.
    select
        substr(
            substr(x,
                   1,
                   instr(x, 'for') - 2),
            instr(x, 'item') + 5
        )
    into l_constraint_name
    from
        (
            select
                replace(p_error.message, '"') x
            from
                dual
        );

    if p_error.is_internal_error then
        -- Access Denied errors raised by application or page authorization should
        -- still show up with the original error message
        if
            p_error.apex_error_code <> 'APEX.AUTHORIZATION.ACCESS_DENIED'
            and p_error.apex_error_code not like 'APEX.SESSION_STATE.%'
        then
            -- log error for example with an autonomous transaction and return
            -- l_reference_id as reference#
            pc_log.log_error('sam_apex_error_handling',
                             apex_error.get_first_ora_error_text(p_error, true)
                             || 'column_alias '
                             || p_error.column_alias
                             || 'row_num  '
                             || p_error.row_num
                             || 'error_backtrace '
                             || p_error.error_backtrace);
            --                       p_error => p_error );
            --

            -- Change the message to the generic error message which doesn't expose
            -- any sensitive information.
            l_result.message := '<li class="jstree-open" id="node_1">'
                                || p_error.component.type
                                || '<ul><li style="margin-left:5em;list-style-type:circle">'
                                || p_error.component.name
                                || '<ul><li style="margin-left:5em;list-style-type:square">'
                                || regexp_substr(p_error.apex_error_code, '[^.]+', 1, 2)
                                || '<ul><li style="margin-left:5em">'
                                || l_constraint_name
                                || '</li></ul></li></ul></li></ul></li>'
--            l_result.message         := p_error.component.type||' => '||p_error.component.name||' => '||regexp_substr(p_error.apex_error_code,'[^.]+',1,2)||' => '||l_constraint_name
                                || '<hr>'
                                || apex_error.get_first_ora_error_text(p_error, true)
                                || '<br><hr>'
                                || nvl(
                replace(p_error.ora_sqlerrm,
                        apex_error.get_first_ora_error_text(p_error, true)),
                nvl(p_error.page_item_name, p_error.apex_error_code)
            )
                                || '<br><hr>'
                                || replace(p_error.message, '"')
                                || '<br><hr>An unexpected internal application error has occurred. Please get in contact with techsupport@sterlingadministration.com for further investigation.<br><hr>'
                                ;

            l_result.display_location := apex_error.c_inline_in_notification;
            l_result.display_location := apex_error.c_inline_with_field_and_notif;
            l_result.additional_info := null;
        end if;
    else
        -- Always show the error as inline error
        -- Note: If you have created manual tabular forms (using the package
        --       apex_item/htmldb_item in the SQL statement) you should still
        --       use "On error page" on that pages to avoid loosing entered data
        l_result.display_location :=
            case
                when l_result.display_location = apex_error.c_on_error_page then
                    apex_error.c_inline_in_notification
                else l_result.display_location
            end;

        -- If it's a constraint violation like
        --
        --   -) ORA-00001: unique constraint violated
        --   -) ORA-02091: transaction rolled back (-> can hide a deferred constraint)
        --   -) ORA-02290: check constraint violated
        --   -) ORA-02291: integrity constraint violated - parent key not found
        --   -) ORA-02292: integrity constraint violated - child record found
        --
        -- we try to get a friendly error message from our constraint lookup configuration.
        -- If we don't find the constraint in our lookup table we fallback to
        -- the original ORA error message.

        -- If an ORA error has been raised, for example a raise_application_error(-20xxx, '...')
        -- in a table trigger or in a PL/SQL package called by a process and we
        -- haven't found the error in our lookup table, then we just want to see
        -- the actual error text and not the full error stack with all the ORA error numbers.
        if
            p_error.ora_sqlcode is not null
            and l_result.message = p_error.message
        then

            --l_result.message:=apex_error.get_first_ora_error_text(p_error,true)||'<br>'||p_error.component.type||' => '||p_error.component.name||' => '||regexp_substr(p_error.apex_error_code,'[^.]+',1,2)||' => '||l_constraint_name||replace(replace(p_error.error_backtrace,'"'),'ORA-',chr(9)||'<br>ORA-');--||apex_debug.tochar(p_error.is_internal_error);
            l_result.message := apex_error.get_first_ora_error_text(p_error => p_error);
        end if;

        -- If no associated page item/tabular form column has been set, we can use
        -- apex_error.auto_set_associated_item to automatically guess the affected
        -- error field by examine the ORA error for constraint names or column names.
        if
            l_result.page_item_name is null
            and l_result.column_alias is null
        then
            apex_error.auto_set_associated_item(
                p_error        => p_error,
                p_error_result => l_result
            );
        end if;

    end if;

    return l_result;
end sam_apex_error_handling;
/


-- sqlcl_snapshot {"hash":"8df9ee618a7a9dac8052fe40eb01a0fb6ab8fe1d","type":"FUNCTION","name":"SAM_APEX_ERROR_HANDLING","schemaName":"SAMQA","sxml":""}