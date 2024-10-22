
#int ldap_is_ldap_url( const char *url )
function ldap_is_ldap_url(url::AbstractString)
    ccall((:ldap_is_ldap_url, libldap), Cint, (Cstring,), url)
end

# int ldap_initialize(LDAP **ldp, char *uri)
function ldap_initialize(ldp_handle_ref::Ref{Ptr{Cvoid}}, uri::AbstractString)
    ccall((:ldap_initialize, libldap), Cint, (Ref{Ptr{Cvoid}}, Cstring), ldp_handle_ref, uri)
end

#char *ldap_err2string( int err );
function ldap_err2string(err::Integer)
    ccall((:ldap_err2string, libldap), Cstring, (Cint,), err)
end

# int ldap_url_parse( const char *url, LDAPURLDesc **ludpp )
function ldap_url_parse(url::AbstractString, ldap_url_desc_handle_ref::Ref{Ptr{LDAPURLDesc}})
    ccall((:ldap_url_parse, libldap), Cint, (Cstring, Ref{Ptr{LDAPURLDesc}}), url, ldap_url_desc_handle_ref)
end

# void ldap_free_urldesc( LDAPURLDesc *ludp );
function ldap_free_urldesc(ldap_url_desc_handle::Ptr{LDAPURLDesc})
    ccall((:ldap_free_urldesc, libldap), Cvoid, (Ptr{LDAPURLDesc},), ldap_url_desc_handle)
end

# int ldap_get_option(LDAP *ld, int option, void *outvalue);
function ldap_get_option(ldp_handle::Ptr{Cvoid}, option::LDAPOption, out_value_ref::Ref{Cint})
    opt_int = Cint(option)
    ccall((:ldap_get_option, libldap), Cint, (Ptr{Cvoid}, Cint, Ref{Cint}), ldp_handle, opt_int, out_value_ref)
end

# int ldap_set_option(LDAP *ld, int option, const void *invalue);
function ldap_set_option(ldp_handle::Ptr{Cvoid}, option::LDAPOption, in_value::T) where {T}
    opt_int = Cint(option)
    in_value_ref = Ref(Cint(in_value))
    ccall((:ldap_set_option, libldap), Cint, (Ptr{Cvoid}, Cint, Ref{Cint}), ldp_handle, opt_int, in_value_ref)
end

# int ldap_simple_bind_s(LDAP *ld, const char *who, const char *passwd);
function ldap_simple_bind_s(ldp_handle::Ptr{Cvoid}, who::Union{AbstractString,Nothing}, password::Union{AbstractString,Nothing})
    ccall((:ldap_simple_bind_s, libldap), Cint, (Ptr{Cvoid}, Cstring, Cstring),
        ldp_handle,
        isnothing(who) ? C_NULL : who,
        isnothing(password) ? C_NULL : password)
end

# int ldap_unbind_s(LDAP *ld);
function ldap_unbind_s(ldp_handle::Ptr{Cvoid})
    ccall((:ldap_unbind_s, libldap), Cint, (Ptr{Cvoid},), ldp_handle)
end

# int ldap_msgfree( LDAPMessage *msg );
function ldap_msgfree(msg_handle::Ptr{Cvoid})
    ccall((:ldap_msgfree, libldap), Cint, (Ptr{Cvoid},), msg_handle)
end

#=
int ldap_search_ext_s(
      LDAP *ld,
      char *base,
      int scope,
      char *filter,
      char *attrs[],
      int attrsonly,
      LDAPControl **serverctrls,
      LDAPControl **clientctrls,
      struct timeval *timeout,
      int sizelimit,
      LDAPMessage **res );
=#
function ldap_search_ext_s(
            ldp_handle::Ptr{Cvoid},
            base::AbstractString,
            scope::Integer,
            ldap_filter::Union{Nothing, AbstractString},
            attr_desc_only::Bool,
            size_limit::Integer,
            result::Ref{Ptr{Cvoid}}
        )
    ccall((:ldap_search_ext_s, libldap), Cint,
        (Ptr{Cvoid}, Cstring, Cint, Cstring, Ptr{Ptr{UInt8}}, Cint,
            Ptr{Cvoid}, Ptr{Cvoid}, Ptr{Cvoid}, Cint, Ref{Ptr{Cvoid}}),
        ldp_handle, base, scope, ldap_filter == nothing ? C_NULL : ldap_filter, C_NULL, attr_desc_only, C_NULL, C_NULL, C_NULL, size_limit, result)
end

# int ldap_count_messages( LDAP *ld, LDAPMessage *result )
function ldap_count_messages(ldp_handle::Ptr{Cvoid}, msg_handle::Ptr{Cvoid})
    ccall((:ldap_count_messages, libldap), Cint, (Ptr{Cvoid}, Ptr{Cvoid}), ldp_handle, msg_handle)
end

# LDAPMessage *ldap_first_message( LDAP *ld, LDAPMessage *result )
function ldap_first_message(ldp_handle::Ptr{Cvoid}, msg_handle::Ptr{Cvoid})
    ccall((:ldap_first_message, libldap), Ptr{Cvoid}, (Ptr{Cvoid}, Ptr{Cvoid}), ldp_handle, msg_handle)
end

# LDAPMessage *ldap_next_message( LDAP *ld, LDAPMessage *message )
function ldap_next_message(ldp_handle::Ptr{Cvoid}, msg_handle::Ptr{Cvoid})
    ccall((:ldap_next_message, libldap), Ptr{Cvoid}, (Ptr{Cvoid}, Ptr{Cvoid}), ldp_handle, msg_handle)
end

# int ldap_msgtype( LDAPMessage *msg );
function ldap_msgtype(msg_handle::Ptr{Cvoid})
    ccall((:ldap_msgtype, libldap), Cint, (Ptr{Cvoid},), msg_handle)
end

# int ldap_msgid( LDAPMessage *msg );
function ldap_msgid(msg_handle::Ptr{Cvoid})
    ccall((:ldap_msgid, libldap), Cint, (Ptr{Cvoid},), msg_handle)
end

#ldap_count_references LDAP_P((
#    LDAP *ld,
#    LDAPMessage *chain ));
function ldap_count_references(ldp_handle::Ptr{Cvoid}, msg_handle::Ptr{Cvoid})
    ccall((:ldap_count_references, libldap), Cint, (Ptr{Cvoid}, Ptr{Cvoid}), ldp_handle, msg_handle)
end

#LDAP_F( int )
#ldap_count_entries LDAP_P((
#    LDAP *ld,
#    LDAPMessage *chain ));
function ldap_count_entries(ldp_handle::Ptr{Cvoid}, msg_handle::Ptr{Cvoid})
    ccall((:ldap_count_entries, libldap), Cint, (Ptr{Cvoid}, Ptr{Cvoid}), ldp_handle, msg_handle)
end

#char * ldap_get_dn LDAP_P((
#    LDAP *ld,
#    LDAPMessage *entry ));
function ldap_get_dn(ldp_handle::Ptr{Cvoid}, entry_handle::Ptr{Cvoid})
    ccall((:ldap_get_dn, libldap), Ptr{UInt8}, (Ptr{Cvoid}, Ptr{Cvoid}), ldp_handle, entry_handle)
end

#LDAP_F( void )
#ldap_memfree LDAP_P((
#    void* p ));
function ldap_memfree(handle::Ptr{T}) where {T}
    ccall((:ldap_memfree, libldap), Cvoid, (Ptr{T},), handle)
end

#LDAP_F( LDAPMessage * )
#ldap_first_entry LDAP_P((
#    LDAP *ld,
#    LDAPMessage *chain ));
function ldap_first_entry(ldp_handle::Ptr{Cvoid}, msg_handle::Ptr{Cvoid})
    ccall((:ldap_first_entry, libldap), Ptr{Cvoid}, (Ptr{Cvoid}, Ptr{Cvoid}), ldp_handle, msg_handle)
end

#LDAP_F( LDAPMessage * )
#ldap_next_entry LDAP_P((
#    LDAP *ld,
#    LDAPMessage *entry ));
function ldap_next_entry(ldp_handle::Ptr{Cvoid}, msg_handle::Ptr{Cvoid})
    ccall((:ldap_next_entry, libldap), Ptr{Cvoid}, (Ptr{Cvoid}, Ptr{Cvoid}), ldp_handle, msg_handle)
end

#LDAP_F( int )
#ldap_get_entry_controls LDAP_P((
#  LDAP      *ld,
#  LDAPMessage   *entry,
#  LDAPControl   ***serverctrls));
function ldap_get_entry_controls(ldp_handle::Ptr{Cvoid}, entry_handle::Ptr{Cvoid}, controls_vec_ref::Ref{Ptr{Ptr{LDAPControl}}})
    ccall((:ldap_get_entry_controls, libldap), Cint, (Ptr{Cvoid}, Ptr{Cvoid}, Ref{Ptr{Ptr{LDAPControl}}}), ldp_handle, entry_handle, controls_vec_ref)
end

# ldap_controls_free() frees a NULL-terminated array of controls.
#=
LDAP_F( void )
ldap_controls_free LDAP_P((
    LDAPControl **ctrls ));
=#
function ldap_controls_free(ctrls_handle::Ptr{Ptr{LDAPControl}})
    ccall((:ldap_controls_free, libldap), Cvoid, (Ptr{Ptr{LDAPControl}},), ctrls_handle)
end

#=
LDAP_F( int )
ldap_parse_result LDAP_P((
    LDAP            *ld,
    LDAPMessage     *res,
    int             *errcodep,
    char            **matcheddnp,
    char            **errmsgp,
    char            ***referralsp,
    LDAPControl     ***serverctrls,
    int             freeit ));
=#
function ldap_parse_result(ldp_handle::Ptr{Cvoid}, result_handle::Ptr{Cvoid},
        err_ref::Ref{Cint}, match_str_ref::Ref{Ptr{UInt8}}, err_msg_ref::Ref{Ptr{UInt8}},
        referralsp_ref::Ref{Ptr{Ptr{UInt8}}}, controls_ref::Ref{Ptr{Ptr{LDAPControl}}}, freeit::Bool)

    ccall((:ldap_parse_result, libldap), Cint, (Ptr{Cvoid}, Ptr{Cvoid}, Ref{Cint}, Ref{Ptr{UInt8}}, Ref{Ptr{UInt8}}, Ref{Ptr{Ptr{UInt8}}}, Ref{Ptr{Ptr{LDAPControl}}}, Cint),
        ldp_handle, result_handle, err_ref, match_str_ref, err_msg_ref, referralsp_ref, controls_ref, freeit)
end

#LDAP_F( LDAPMessage * )
#ldap_first_reference LDAP_P((
#    LDAP *ld,
#    LDAPMessage *chain ));
function ldap_first_reference(ldp_handle::Ptr{Cvoid}, msg_handle::Ptr{Cvoid})
    ccall((:ldap_first_reference, libldap), Ptr{Cvoid}, (Ptr{Cvoid}, Ptr{Cvoid}), ldp_handle, msg_handle)
end

#LDAP_F( LDAPMessage * )
#ldap_next_reference LDAP_P((
#    LDAP *ld,
#    LDAPMessage *ref ));
function ldap_next_reference(ldp_handle::Ptr{Cvoid}, msg_handle::Ptr{Cvoid})
    ccall((:ldap_next_reference, libldap), Ptr{Cvoid}, (Ptr{Cvoid}, Ptr{Cvoid}), ldp_handle, msg_handle)
end

#=
LDAP_F( void )
ldap_memvfree LDAP_P((
    void** v ));
=#
function ldap_memvfree(ptr::Ptr{Ptr{T}}) where {T}
    ccall((:ldap_memvfree, libldap), Cvoid, (Ptr{Ptr{T}},), ptr)
end

#LDAP_F( char * )
#ldap_first_attribute LDAP_P((
#  LDAP *ld,
#  LDAPMessage *entry,
#  BerElement **ber ));
function ldap_first_attribute(ldp_handle::Ptr{Cvoid}, entry_handle::Ptr{Cvoid}, ber_element_handle_ref::Ref{Ptr{Cvoid}})
    ccall((:ldap_first_attribute, libldap), Ptr{UInt8}, (Ptr{Cvoid}, Ptr{Cvoid}, Ref{Ptr{Cvoid}}), ldp_handle, entry_handle, ber_element_handle_ref)
end

#=
LDAP_F( char * )
ldap_next_attribute LDAP_P((
    LDAP *ld,
    LDAPMessage *entry,
    BerElement *ber ));
=#
function ldap_next_attribute(ldp_handle::Ptr{Cvoid}, entry_handle::Ptr{Cvoid}, ber_element_handle::Ptr{Cvoid})
    ccall((:ldap_next_attribute, libldap), Ptr{UInt8}, (Ptr{Cvoid}, Ptr{Cvoid}, Ptr{Cvoid}), ldp_handle, entry_handle, ber_element_handle)
end

#LDAP_F( char ** )
#ldap_get_values LDAP_P((
#    LDAP *ld,
#    LDAPMessage *entry,
#    LDAP_CONST char *target ));
function ldap_get_values(ldp_handle::Ptr{Cvoid}, entry_handle::Ptr{Cvoid}, attribute::AbstractString)
    ccall((:ldap_get_values, libldap), Ptr{Ptr{UInt8}}, (Ptr{Cvoid}, Ptr{Cvoid}, Cstring), ldp_handle, entry_handle, attribute)
end

#LDAP_F( void )
#ldap_value_free LDAP_P((
#    char **vals ));
function ldap_value_free(vals::Ptr{Ptr{UInt8}})
    ccall((:ldap_value_free, libldap), Cvoid, (Ptr{Ptr{UInt8}},), vals)
end
