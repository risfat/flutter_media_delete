package devtech365.flutter_media_delete

import android.app.Activity
import android.content.ContentResolver
import android.content.ContentUris
import android.content.IntentSender
import android.database.Cursor
import android.net.Uri
import android.os.Build
import android.provider.MediaStore
import android.util.Log
import androidx.annotation.NonNull
import io.flutter.embedding.engine.plugins.FlutterPlugin
import io.flutter.embedding.engine.plugins.activity.ActivityAware
import io.flutter.embedding.engine.plugins.activity.ActivityPluginBinding
import io.flutter.plugin.common.MethodCall
import io.flutter.plugin.common.MethodChannel
import io.flutter.plugin.common.MethodChannel.MethodCallHandler
import io.flutter.plugin.common.MethodChannel.Result
import java.io.File

class FlutterMediaDeletePlugin : FlutterPlugin, MethodCallHandler, ActivityAware {
  private lateinit var channel: MethodChannel
  private var activity: Activity? = null
  private val REQUEST_CODE_DELETE = 1001
  private var pendingResult: Result? = null

  override fun onAttachedToEngine(@NonNull flutterPluginBinding: FlutterPlugin.FlutterPluginBinding) {
    channel = MethodChannel(flutterPluginBinding.binaryMessenger, "flutter_media_delete")
    channel.setMethodCallHandler(this)
  }

  override fun onDetachedFromEngine(@NonNull binding: FlutterPlugin.FlutterPluginBinding) {
    channel.setMethodCallHandler(null)
  }

  override fun onMethodCall(@NonNull call: MethodCall, @NonNull result: Result) {
    if (activity == null) {
      result.error("NO_ACTIVITY", "Plugin requires a foreground activity.", null)
      return
    }

    when (call.method) {
      "deleteMediaFile" -> {
        val filePath = call.argument<String>("filePath")
        if (filePath != null) {
          deleteMediaFile(filePath, result)
        } else {
          result.error("INVALID_ARGUMENT", "File path cannot be null", null)
        }
      }
      "deleteMediaFolder" -> {
        val folderPath = call.argument<String>("folderPath")
        if (folderPath != null) {
          deleteMediaFilesInFolder(folderPath, result)
        } else {
          result.error("INVALID_ARGUMENT", "Folder path cannot be null", null)
        }
      }
      else -> result.notImplemented()
    }
  }

  private fun deleteMediaFile(filePath: String, result: Result) {
    val resolver: ContentResolver = activity!!.contentResolver
    val file = File(filePath)
    val projection = arrayOf(MediaStore.MediaColumns._ID)
    val selection = "${MediaStore.MediaColumns.DATA}=?"
    val selectionArgs = arrayOf(file.absolutePath)

    // Try to find the media file in all three categories: Video, Audio, Images
    val mediaUri = findMediaUri(filePath, resolver, selection, selectionArgs)

    if (mediaUri != null) {
      if (Build.VERSION.SDK_INT >= Build.VERSION_CODES.Q) {
        try {
          val deleteRequest = MediaStore.createDeleteRequest(resolver, listOf(mediaUri)).intentSender
          activity!!.startIntentSenderForResult(deleteRequest, REQUEST_CODE_DELETE, null, 0, 0, 0)
          pendingResult = result
        } catch (e: Exception) {
          Log.e("FlutterMediaDelete", "Error deleting file", e)
          result.error("ERROR", "Delete request failed", e.message)
        }
      } else {
        // Handle file deletion directly for older Android versions
        try {
          val rowsDeleted = resolver.delete(mediaUri, null, null)
          if (rowsDeleted > 0) {
            result.success("File deleted successfully")
          } else {
            result.error("DELETE_FAILED", "Failed to delete file", null)
          }
        } catch (e: Exception) {
          Log.e("FlutterMediaDelete", "Error deleting file", e)
          result.error("ERROR", "Failed to delete file", e.message)
        }
      }
    } else {
      result.error("FILE_NOT_FOUND", "File not found", null)
    }
  }

  private fun deleteMediaFilesInFolder(folderPath: String, result: Result) {
    val resolver: ContentResolver = activity!!.contentResolver
    val selection = "${MediaStore.MediaColumns.DATA} LIKE ?"
    val selectionArgs = arrayOf("$folderPath/%")
    val urisToDelete = mutableListOf<Uri>()

    // Fetch all media types (Video, Audio, Images) from MediaStore
    urisToDelete.addAll(queryMediaUris(MediaStore.Video.Media.EXTERNAL_CONTENT_URI, resolver, selection, selectionArgs))
    urisToDelete.addAll(queryMediaUris(MediaStore.Audio.Media.EXTERNAL_CONTENT_URI, resolver, selection, selectionArgs))
    urisToDelete.addAll(queryMediaUris(MediaStore.Images.Media.EXTERNAL_CONTENT_URI, resolver, selection, selectionArgs))

    if (urisToDelete.isEmpty()) {
      result.success("No media files found to delete")
      return
    }

    try {
      if (Build.VERSION.SDK_INT >= Build.VERSION_CODES.Q) {
        val deleteRequest = MediaStore.createDeleteRequest(resolver, urisToDelete).intentSender
        activity!!.startIntentSenderForResult(deleteRequest, REQUEST_CODE_DELETE, null, 0, 0, 0)
        pendingResult = result
      } else {
        // Directly delete files for older Android versions
        var success = true
        for (uri in urisToDelete) {
          val rowsDeleted = resolver.delete(uri, null, null)
          if (rowsDeleted <= 0) {
            success = false
          }
        }
        if (success) {
          result.success("Files deleted successfully")
        } else {
          result.error("DELETE_FAILED", "Failed to delete some files", null)
        }
      }
    } catch (e: Exception) {
      Log.e("FlutterMediaDelete", "Error deleting files", e)
      result.error("ERROR", "Failed to create delete request", e.message)
    }
  }


  private fun findMediaUri(filePath: String, resolver: ContentResolver, selection: String, selectionArgs: Array<String>): Uri? {
    val mediaUris = arrayOf(
      MediaStore.Video.Media.EXTERNAL_CONTENT_URI,
      MediaStore.Audio.Media.EXTERNAL_CONTENT_URI,
      MediaStore.Images.Media.EXTERNAL_CONTENT_URI
    )

    mediaUris.forEach { uri ->
      resolver.query(uri, arrayOf(MediaStore.MediaColumns._ID), selection, selectionArgs, null)?.use { cursor ->
        if (cursor.moveToFirst()) {
          val id = cursor.getLong(cursor.getColumnIndexOrThrow(MediaStore.MediaColumns._ID))
          return ContentUris.withAppendedId(uri, id)
        }
      }
    }
    return null
  }

  private fun queryMediaUris(mediaUri: Uri, resolver: ContentResolver, selection: String, selectionArgs: Array<String>): List<Uri> {
    val urisToDelete = mutableListOf<Uri>()
    resolver.query(mediaUri, arrayOf(MediaStore.MediaColumns._ID), selection, selectionArgs, null)?.use { cursor ->
      val idColumn = cursor.getColumnIndexOrThrow(MediaStore.MediaColumns._ID)
      while (cursor.moveToNext()) {
        val id = cursor.getLong(idColumn)
        val uri = ContentUris.withAppendedId(mediaUri, id)
        urisToDelete.add(uri)
      }
    }
    return urisToDelete
  }

  override fun onAttachedToActivity(binding: ActivityPluginBinding) {
    this.activity = binding.activity
    binding.addActivityResultListener { requestCode, resultCode, _ ->
      if (requestCode == REQUEST_CODE_DELETE) {
        if (resultCode == Activity.RESULT_OK) {
          Log.i("FlutterMediaDelete", "Files deleted successfully")
          pendingResult?.success("Files deleted successfully")
        } else {
          Log.i("FlutterMediaDelete", "File deletion denied by user")
          pendingResult?.error("USER_DENIED", "File deletion was denied by the user", null)
        }
        pendingResult = null
        true
      } else {
        false
      }
    }
  }


  override fun onDetachedFromActivityForConfigChanges() {
    this.activity = null
  }

  override fun onReattachedToActivityForConfigChanges(binding: ActivityPluginBinding) {
    this.activity = binding.activity
  }

  override fun onDetachedFromActivity() {
    this.activity = null
  }
}
