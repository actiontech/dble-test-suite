/* Copyright (C) 2016-2020 ActionTech.
 * License: https://www.mozilla.org/en-US/MPL/2.0 MPL version 2 or higher.
 */
package com.actiontech.dble;

import com.jcraft.jsch.UserInfo;

/**
 * This class provide interface to feedback information to the user.
 */
public class MyUserInfo implements UserInfo {

	@Override
	public String getPassphrase() {
		System.out.println("MyUserInfo.getPassphrase()");
		return null;
	}

	@Override
	public String getPassword() {
		System.out.println("MyUserInfo.getPassword()");
		return null;
	}

	@Override
	public boolean promptPassphrase(final String arg0) {
		System.out.println("MyUserInfo.promptPassphrase()");
		System.out.println(arg0);
		return false;
	}

	@Override
	public boolean promptPassword(final String arg0) {
		System.out.println("MyUserInfo.promptPassword()");
		System.out.println(arg0);
		return false;
	}

	@Override
	public boolean promptYesNo(final String arg0) {
		System.out.println("MyUserInfo.promptYesNo()");
		System.out.println(arg0);
//		if (arg0.contains("The authenticity of host")) {
//			return true;
//		}
		return false;
	}

	@Override
	public void showMessage(final String arg0) {
		System.out.println("MyUserInfo.showMessage()");
	}
}