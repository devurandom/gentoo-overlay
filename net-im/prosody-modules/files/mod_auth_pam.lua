-- PAM authentication for Prosody
-- Copyright (C) 2013 Kim Alvefur
--
-- Requires https://github.com/devurandom/lua-pam
-- and LuaPosix

local name = "PAM";
local log = require "util.logger".init("auth_pam");

local posix = require "posix";
local pam = require "pam";
local io = require "io"

local util_sasl_new = require "util.sasl".new;

local provider = {};

function provider.test_password(username, password)
	local function conversation(messages)
		local responses = {}

		for i, message in ipairs(messages) do
			local msg_style, msg = message[1], message[2]

			if msg_style == pam.PROMPT_ECHO_OFF then
				-- Assume PAM asks us for the password
				responses[i] = {password, 0}
			elseif msg_style == pam.PROMPT_ECHO_ON then
				responses[i] = {username, 0}
			elseif msg_style == pam.ERROR_MSG then
				log("info", "ERROR: %s", msg);
				responses[i] = {"", 0}
			elseif msg_style == pam.TEXT_INFO then
				log("info", "INFO: %s", msg);
				responses[i] = {"", 0}
			else
				error("Unsupported conversation message style: " .. msg_style)
			end
		end

		return responses
	end

	local handle, err = pam.start("xmpp", username, {conversation, nil});
	if not handle then
		log("info", "Authentication failed: %s", err);
		return nil;
	end

	local status, err = handle:authenticate()
	if not status then
		log("info", "Authentication failed: %s", err);
		return nil;
	end
		
	local status, err = handle:endx(pam.SUCCESS)
	if not status then
		log("info", "Authentication failed: %s", err);
		return nil;
	end

	return true;
end

function provider.get_password(username)
	return nil, "Passwords unavailable for "..name;
end

function provider.set_password(username, password)
	return nil, "Passwords unavailable for "..name;
end

function provider.user_exists(username)
	return not not posix.getpasswd(username);
end

function provider.create_user(username, password)
	return nil, "Account creation/modification not available with "..name;
end

function provider.get_sasl_handler()
	return util_sasl_new(module.host, {
		plain_test = function(sasl, username, password, realm)
			return provider.test_password(username, password), true
		end
	});
end

module:provides("auth", provider);
