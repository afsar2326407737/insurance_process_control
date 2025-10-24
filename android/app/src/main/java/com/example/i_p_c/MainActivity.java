package com.example.i_p_c; 
import androidx.annotation.NonNull;
import androidx.annotation.Nullable;
import androidx.core.app.ActivityCompat;
import androidx.core.content.ContextCompat;
import androidx.core.content.FileProvider;

import android.Manifest;
import android.content.Intent;
import android.content.pm.PackageManager;
import android.net.Uri;
import android.os.Environment;
import android.os.Bundle;
import android.provider.MediaStore;

import java.io.File;
import java.text.SimpleDateFormat;
import java.util.Date;
import java.util.Locale;

import io.flutter.embedding.android.FlutterActivity;
import io.flutter.embedding.engine.FlutterEngine;
import io.flutter.plugin.common.MethodChannel;

public class MainActivity extends FlutterActivity {
    private static final int REQUEST_IMAGE_CAPTURE = 1001;
    private MethodChannel.Result pendingResult;
    private Uri photoURI;
    private File photoFile;

    @Override
    public void configureFlutterEngine(@NonNull FlutterEngine flutterEngine) {
        super.configureFlutterEngine(flutterEngine);

        new MethodChannel(flutterEngine.getDartExecutor().getBinaryMessenger(),
                "samples.flutter.dev/camera")
                .setMethodCallHandler((call, result) -> {
                    if (call.method.equals("takePicture")) {
                        // save for later callback
                        pendingResult = result;

                        // Check permission before proceeding
                        if (ContextCompat.checkSelfPermission(this, Manifest.permission.CAMERA)
                                != PackageManager.PERMISSION_GRANTED) {
                            ActivityCompat.requestPermissions(
                                    this,
                                    new String[]{Manifest.permission.CAMERA},
                                    REQUEST_IMAGE_CAPTURE
                            );
                        } else {
                            dispatchTakePictureIntent();
                        }
                    } else {
                        result.notImplemented();
                    }
                });
    }

    private void dispatchTakePictureIntent() {
        Intent takePictureIntent = new Intent(MediaStore.ACTION_IMAGE_CAPTURE);
        if (takePictureIntent.resolveActivity(getPackageManager()) != null) {
            try {
                photoFile = createImageFile();
                photoURI = FileProvider.getUriForFile(
                        this,
                        getPackageName() + ".provider",
                        photoFile
                );
                takePictureIntent.putExtra(MediaStore.EXTRA_OUTPUT, photoURI);
                startActivityForResult(takePictureIntent, REQUEST_IMAGE_CAPTURE);
                System.out.print("Photo will be saved to (absolute path): " + photoFile.getAbsolutePath());
            } catch (Exception e) {
                if (pendingResult != null) {
                    pendingResult.error("file_error", "Could not create file: " + e.getMessage(), null);
                    pendingResult = null;
                }
            }
        } else {
            if (pendingResult != null) {
                pendingResult.error("no_camera", "No camera app available", null);
                pendingResult = null;
            }
        }
    }

    private File createImageFile() {
        String timeStamp = new SimpleDateFormat("yyyyMMdd_HHmmss", Locale.getDefault()).format(new Date());
        String imageFileName = "JPEG_" + timeStamp + "_";
        File storageDir = getExternalFilesDir(Environment.DIRECTORY_PICTURES);
        return new File(storageDir, imageFileName + ".jpg");
    }

    @Override
    protected void onActivityResult(int requestCode, int resultCode, @Nullable Intent data) {
        super.onActivityResult(requestCode, resultCode, data);

        if (requestCode == REQUEST_IMAGE_CAPTURE && pendingResult != null) {
            if (resultCode == RESULT_OK) {
                pendingResult.success(photoFile.getAbsolutePath());
                System.out.println("Photo saved to: " + photoFile.getAbsolutePath());
            } else {
                pendingResult.error("cancelled", "User cancelled the camera", null);
            }
            pendingResult = null;
        }
    }
}
