package com.demo.jdbc;

import java.io.BufferedWriter;
import java.io.File;
import java.io.FileOutputStream;
import java.io.IOException;
import java.io.OutputStreamWriter;
import java.nio.charset.StandardCharsets;

public class MyWriter {

	private BufferedWriter writer = null;

	public MyWriter(String fileName) {
		this(new File(fileName));
	}

	public MyWriter(File file) {
		try {
			FileOutputStream fileOutputStream=new FileOutputStream(file, true);
//			OutputStreamWriter outputstreamWriter = new OutputStreamWriter(fileOutputStream, StandardCharsets.UTF_8);
			OutputStreamWriter outputstreamWriter = new OutputStreamWriter(fileOutputStream, StandardCharsets.US_ASCII);
//			writer = new BufferedWriter(new FileWriter(file, true));
			writer = new BufferedWriter(outputstreamWriter);
		} catch (IOException e) {
			e.printStackTrace();
		}
	}

	public void write(String str) {
		try {
			writer.write(str);
		} catch (IOException e) {
			e.printStackTrace();
		}
	}

	public void close() {
		if (writer != null) {
			try {
				writer.close();
			} catch (IOException e1) {
				e1.printStackTrace();
			}
		}
	}

}
